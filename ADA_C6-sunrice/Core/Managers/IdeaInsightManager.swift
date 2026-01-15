//
//  IdeaInsightManager.swift
//  ADA_C6-sunrice
//
//  Created by Antigravity on 26/11/25.
//

import Foundation
import Combine

@MainActor
final class IdeaInsightManager: ObservableObject {
    let insightService: IdeaInsightServicing  // Internal for refresh access
    weak var timerManager: TimerManager?  // Delegate for polling
    
    @Published var insights: [IdeaInsightDTO] = []
    @Published var isAnalyzing: Bool = false
    @Published var analysisProgress: String = ""
    @Published var analysisError: String?
    
    init(insightService: IdeaInsightServicing) {
        self.insightService = insightService
    }
    
    func setTimerManager(_ manager: TimerManager) {
        self.timerManager = manager
    }
    
    // MARK: - Analysis Operations
    
    func analyzeAllIdeas(sessionId: Int, isHost: Bool) async {
        isAnalyzing = true
        analysisError = nil  // Clear previous error for retry
        
        if isHost {
            // Host: Call batch analyze function once
            await analyzeIdeasAsHost(sessionId: sessionId)
            isAnalyzing = false  // Host sets to false when done
        } else {
            // Guest: Poll for existing insights (keeps isAnalyzing=true until polling completes)
            // We don't know the expected count upfront, so poll until stable
            await fetchInsightsAsGuest(sessionId: sessionId)
        }
    }
    
    // MARK: - Host Logic
    
    private func analyzeIdeasAsHost(sessionId: Int) async {
        analysisProgress = "Analyzing all ideas..."
        
        do {
            let response = try await insightService.analyzeIdeasBatch(
                sessionId: sessionId,
                greenIdeaIds: nil  // Auto-discover all green ideas
            )
            
            if response.success {
                print("✅ Batch analysis complete: \(response.analyzed) ideas analyzed")
                analysisProgress = "Analysis complete!"
                
                // Fetch the insights to populate local state
                let fetchedInsights = try await insightService.fetchIdeaInsights(sessionId: sessionId)
                insights = fetchedInsights
                print("✅ Retrieved \(insights.count) insights")
            } else {
                print("⚠️ Batch analysis partially failed: \(response.failed) failures")
                analysisProgress = "Analysis complete with \(response.failed) errors"
                analysisError = "Failed to analyze \(response.failed) ideas"
                
                // Still fetch what we have
                let fetchedInsights = try await insightService.fetchIdeaInsights(sessionId: sessionId)
                insights = fetchedInsights
            }
        } catch {
            print("❌ Error in batch analysis: \(error)")
            analysisError = "Failed to analyze ideas: \(error.localizedDescription)"
            analysisProgress = "Analysis failed"
        }
    }
    
    // MARK: - Guest Logic
    
    private func fetchInsightsAsGuest(sessionId: Int) async {
        analysisProgress = "Waiting for host to complete analysis..."
        
        guard let timerManager = timerManager else {
            print("❌ TimerManager not set, cannot poll for insights")
            return
        }
        
        var previousCount = 0
        var stableCount = 0
        
        // Register polling action
        timerManager.registerPollingAction(id: "insights_fetch") { [weak self] in
            guard let self = self else { return }
            
            do {
                let fetchedInsights = try await self.insightService.fetchIdeaInsights(sessionId: sessionId)
                
                await MainActor.run {
                    let currentCount = fetchedInsights.count
                    
                    // Check if count is stable (hasn't changed for 2 polling cycles)
                    if currentCount == previousCount && currentCount > 0 {
                        stableCount += 1
                        if stableCount >= 2 {
                            // Count stable for 2 cycles, assume analysis complete
                            self.insights = fetchedInsights
                            self.analysisProgress = "Analysis complete!"
                            self.isAnalyzing = false
                            print("✅ Guest: Retrieved \(self.insights.count) insights")
                            timerManager.unregisterPollingAction(id: "insights_fetch")
                        } else {
                            self.analysisProgress = "Verifying completion (\(currentCount) insights)..."
                        }
                    } else {
                        // Count changed, reset stability counter
                        stableCount = 0
                        previousCount = currentCount
                        self.analysisProgress = "Receiving insights (\(currentCount))..."
                        print("⏳ Guest: \(currentCount) insights received...")
                    }
                }
            } catch {
                print("⚠️ Guest: Error fetching insights: \(error)")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    func clearInsights() {
        insights = []
        analysisProgress = ""
        analysisError = nil
        stopFetchingInsights()
    }
    
    func stopFetchingInsights() {
        timerManager?.unregisterPollingAction(id: "insights_fetch")
    }
}

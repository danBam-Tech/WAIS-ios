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
    
    func analyzeAllIdeas(sessionId: Int, greenIdeaIds: [Int], isHost: Bool) async {
        isAnalyzing = true
        analysisError = nil  // Clear previous error for retry
        
        if isHost {
            // Host: Call analyze-idea for each green idea
            await analyzeIdeasAsHost(sessionId: sessionId, greenIdeaIds: greenIdeaIds)
            isAnalyzing = false  // Host sets to false when done
        } else {
            // Guest: Poll for existing insights (keeps isAnalyzing=true until polling completes)
            await fetchInsightsAsGuest(sessionId: sessionId, expectedCount: greenIdeaIds.count)
        }
    }
    
    // MARK: - Host Logic
    
    private func analyzeIdeasAsHost(sessionId: Int, greenIdeaIds: [Int]) async {
        let total = greenIdeaIds.count
        
        for (index, ideaId) in greenIdeaIds.enumerated() {
            if Task.isCancelled {
                print("🛑 Analysis cancelled")
                return
            }
            
            analysisProgress = "Analyzing idea \(index + 1) of \(total)..."
            
            do {
                let response = try await insightService.analyzeIdea(
                    sessionId: sessionId,
                    greenIdeaId: ideaId
                )
                
                if response.success {
                    insights.append(response.insight)
                    print("✅ Analyzed idea \(ideaId)")
                }
            } catch {
                print("❌ Error analyzing idea \(ideaId): \(error)")
                analysisError = "Failed to analyze some ideas"
            }
        }
        
        analysisProgress = "Analysis complete!"
        print("✅ All ideas analyzed: \(insights.count) insights")
    }
    
    // MARK: - Guest Logic
    
    private func fetchInsightsAsGuest(sessionId: Int, expectedCount: Int) async {
        analysisProgress = "Waiting for host to complete analysis..."
        
        guard let timerManager = timerManager else {
            print("❌ TimerManager not set, cannot poll for insights")
            return
        }
        
        // Register polling action
        timerManager.registerPollingAction(id: "insights_fetch") { [weak self] in
            guard let self = self else { return }
            
            do {
                let fetchedInsights = try await self.insightService.fetchIdeaInsights(sessionId: sessionId)
                
                await MainActor.run {
                    if fetchedInsights.count >= expectedCount {
                        self.insights = fetchedInsights
                        self.analysisProgress = "Analysis complete!"
                        self.isAnalyzing = false  // Guest sets to false when done
                        print("✅ Guest: Retrieved \(self.insights.count) insights")
                        // Unregister after success
                        timerManager.unregisterPollingAction(id: "insights_fetch")
                    } else {
                        self.analysisProgress = "Waiting for analysis (\(fetchedInsights.count)/\(expectedCount))..."
                        print("⏳ Guest: \(fetchedInsights.count)/\(expectedCount) insights ready...")
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

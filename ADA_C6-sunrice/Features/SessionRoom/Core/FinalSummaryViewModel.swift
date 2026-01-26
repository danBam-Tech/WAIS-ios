//
//  FinalSummaryViewModel.swift
//  ADA_C6-sunrice
//
//  Created by Antigravity on 23/01/26.
//  Extracted from SessionRoomViewModel for better separation of concerns.
//

import Foundation
import Combine

@MainActor
final class FinalSummaryViewModel: ObservableObject {
    // MARK: - Dependencies
    private let insightManager: IdeaInsightManager
    weak var coordinator: SessionCoordinator?
    
    // MARK: - Published State
    @Published var showExitAlert: Bool = false
    
    // MARK: - Delegated State (from IdeaInsightManager)
    var ideaInsights: [IdeaInsightDTO] { insightManager.insights }
    var isAnalyzingIdeas: Bool { insightManager.isAnalyzing }
    var analysisProgress: String { insightManager.analysisProgress }
    var analysisError: String? { insightManager.analysisError }
    
    // MARK: - Private State
    private let sessionId: Int64
    
    // MARK: - Initialization
    
    init(sessionId: Int64, insightManager: IdeaInsightManager) {
        self.sessionId = sessionId
        self.insightManager = insightManager
    }
    
    // MARK: - Insights Management
    
    func refreshInsightsFromDatabase() async {
        print("📥 Refreshing insights from database...")
        do {
            let freshInsights = try await insightManager.insightService.fetchIdeaInsights(
                sessionId: Int(sessionId)
            )
            await MainActor.run {
                insightManager.insights = freshInsights
                print("✅ Refreshed \(freshInsights.count) insights")
            }
        } catch {
            print("❌ Error refreshing insights: \(error)")
        }
    }
    
    // MARK: - Navigation
    
    func exitToLobby() {
        coordinator?.exitToHome()
    }
}

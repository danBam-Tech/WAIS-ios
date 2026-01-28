//
//  RoundSummaryViewModel.swift
//  ADA_C6-sunrice
//
//  Created by Antigravity on 23/01/26.
//  Extracted from SessionRoomViewModel for better separation of concerns.
//

import Foundation
import Combine

@MainActor
final class RoundSummaryViewModel: ObservableObject {
    // MARK: - Dependencies
    private let summaryManager: SummaryManager
    private let ideaManager: IdeaManager
    weak var coordinator: SessionCoordinator?
    
    // MARK: - Delegated State (from SummaryManager)
    var summary: IdeaSummary? { summaryManager.summary }
    var isLoadingSummary: Bool { summaryManager.isLoadingSummary }
    var summaryError: String? { summaryManager.summaryError }
    
    // MARK: - Delegated State (from IdeaManager)
    var serverIdeas: [IdeaDTO] { ideaManager.serverIdeas }
    var serverComments: [IdeaCommentDTO] { ideaManager.serverComments }
    
    // MARK: - Private State
    private let sessionId: Int64
    private let isHost: Bool
    
    // MARK: - Initialization
    
    init(sessionId: Int64, isHost: Bool, summaryManager: SummaryManager, ideaManager: IdeaManager) {
        self.sessionId = sessionId
        self.isHost = isHost
        self.summaryManager = summaryManager
        self.ideaManager = ideaManager
    }
    
    // MARK: - Summary Management
    
    func fetchSummary(roundType: RoundType?) async {
        guard let roundType = roundType else {
            print("⏭️ No summary available for this round type")
            return
        }
        
        await summaryManager.fetchSummary(sessionId: Int(sessionId), roundType: roundType, isHost: isHost)
    }
    
    // MARK: - Navigation
    
    func advanceToNextRound() {
        coordinator?.hostAdvanceToNextRound()
    }
}

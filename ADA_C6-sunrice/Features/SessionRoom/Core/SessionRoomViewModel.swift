//
//  SessionRoomViewModel.swift
//  ADA_C6-sunrice
//
//  Created by Hanna Nadia Savira on 19/11/25.
//  Refactored by Antigravity on 23/01/26.
//  Simplified to delegate to SessionCoordinator.
//

import Combine
import Foundation
import SwiftUI

// MARK: - Supporting Types

struct RoomPart {
    let title: String
    let type: MessageCardType
}

enum RoomType {
    case fact, idea, buildon, benefit, risk, feeling

    var shared: RoomPart {
        switch self {
        case .fact:
            return .init(title: "Facts & Info", type: .white)
        case .idea:
            return .init(title: "Idea", type: .green)
        case .buildon:
            return .init(title: "Build On", type: .darkGreen)
        case .benefit:
            return .init(title: "Benefits", type: .yellow)
        case .risk:
            return .init(title: "Risks", type: .black)
        case .feeling:
            return .init(title: "Feeling", type: .red)
        }
    }
}

struct Message {
    let text: String
    let type: MessageCardType
}

// MARK: - SessionRoomViewModel

@MainActor
final class SessionRoomViewModel: ObservableObject {
    // MARK: - Dependencies
    private let coordinator: SessionCoordinator
    
    // MARK: - Published State
    // These are @Published to support SwiftUI bindings ($vm.property)
    @Published var inputText: String = ""
    @Published var showRoundSummary: Bool = false
    @Published var showCommentSheet: Bool = false
    @Published var showFinalSummary: Bool = false
    @Published var shouldExitToHome: Bool = false
    @Published var isSessionFinished: Bool = false
    @Published var showInstruction: Bool = true
    @Published var isTimeUp: Bool = false
    
    @Published var messages: [Message] = []  // For backward compatibility
    
    // MARK: - Delegated State (Ready-only from Coordinator)
    var isLoading: Bool { coordinator.isLoading }
    var deadline: Date { coordinator.deadline }
    var prompt: String { coordinator.prompt }
    var roomType: SessionRoom { coordinator.roomType }
    var selectedIdeaForComment: IdeaDTO? {
        get { coordinator.selectedIdeaForComment }
        set { coordinator.selectedIdeaForComment = newValue }
    }
    var hasFetchedInsights: Bool {
        get { coordinator.hasFetchedInsights }
        set { coordinator.hasFetchedInsights = newValue }
    }
    var isCommentRound: Bool { coordinator.isCommentRound }
    
    // MARK: - Delegated State (from InputViewModel)
    var isSendingMessage: Bool { coordinator.inputViewModel.isSendingMessage }
    
    // MARK: - Delegated State (from IdeaManager)
    var localIdeas: [LocalIdea] { coordinator.ideaManager.localIdeas }
    var serverIdeas: [IdeaDTO] { coordinator.ideaManager.serverIdeas }
    var serverComments: [IdeaCommentDTO] { coordinator.ideaManager.serverComments }
    var commentCounts: [Int64: CommentCounts] { coordinator.ideaManager.commentCounts }
    var isUploadingIdeas: Bool { coordinator.ideaManager.isUploadingIdeas }
    
    // MARK: - Delegated State (from SummaryManager)
    var summary: IdeaSummary? { coordinator.summaryManager.summary }
    var isLoadingSummary: Bool { coordinator.summaryManager.isLoadingSummary }
    var summaryError: String? { coordinator.summaryManager.summaryError }
    
    // MARK: - Delegated State (from IdeaInsightManager)
    var ideaInsights: [IdeaInsightDTO] { coordinator.insightManager.insights }
    var isAnalyzingIdeas: Bool { coordinator.insightManager.isAnalyzing }
    var analysisProgress: String { coordinator.insightManager.analysisProgress }
    var analysisError: String? { coordinator.insightManager.analysisError }
    
    // MARK: - Computed Properties
    let sessionId: Int64
    let isHost: Bool
    var currentTypeId: Int64? { coordinator.currentTypeId }
    
    // Services (public for shared access)
    let ideaService: IdeaServicing
    let roundManager: RoundManager
    let ideaManager: IdeaManager
    let summaryManager: SummaryManager
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(id: Int64, isHost: Bool = false, sessionService: SessionServicing, ideaService: IdeaServicing, summaryService: SummaryServicing, insightService: IdeaInsightServicing) {
        self.sessionId = id
        self.isHost = isHost
        self.ideaService = ideaService
        
        // Create coordinator
        self.coordinator = SessionCoordinator(
            sessionId: id,
            isHost: isHost,
            sessionService: sessionService,
            ideaService: ideaService,
            summaryService: summaryService,
            insightService: insightService
        )
        
        // Expose managers for backward compatibility
        self.roundManager = coordinator.roundManager
        self.ideaManager = coordinator.ideaManager
        self.summaryManager = coordinator.summaryManager
        
        setupCoordinatorBindings()
    }
    
    // Convenience initializer for default services
    convenience init(id: Int64, isHost: Bool = false) {
        self.init(
            id: id,
            isHost: isHost,
            sessionService: SessionService(client: supabaseManager),
            ideaService: IdeaService(client: supabaseManager),
            summaryService: SummaryService(client: supabaseManager),
            insightService: IdeaInsightService(client: supabaseManager)
        )
    }
    
    private func setupCoordinatorBindings() {
        // Sync coordinator @Published properties TO this ViewModel's @Published properties
        coordinator.$showRoundSummary.receive(on: RunLoop.main).assign(to: &$showRoundSummary)
        coordinator.$showCommentSheet.receive(on: RunLoop.main).assign(to: &$showCommentSheet)
        coordinator.$showFinalSummary.receive(on: RunLoop.main).assign(to: &$showFinalSummary)
        coordinator.$shouldExitToHome.receive(on: RunLoop.main).assign(to: &$shouldExitToHome)
        coordinator.$isSessionFinished.receive(on: RunLoop.main).assign(to: &$isSessionFinished)
        coordinator.$showInstruction.receive(on: RunLoop.main).assign(to: &$showInstruction)
        coordinator.$isTimeUp.receive(on: RunLoop.main).assign(to: &$isTimeUp)
        
        // Propagate other coordinator changes to trigger view updates
        coordinator.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
        
        // Propagate input ViewModel changes
        coordinator.inputViewModel.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
        
        // Sync this ViewModel's @Published properties BACK to coordinator when changed by View
        $showRoundSummary.sink { [weak self] in self?.coordinator.showRoundSummary = $0 }.store(in: &cancellables)
        $showCommentSheet.sink { [weak self] in self?.coordinator.showCommentSheet = $0 }.store(in: &cancellables)
        $showFinalSummary.sink { [weak self] in self?.coordinator.showFinalSummary = $0 }.store(in: &cancellables)
        $shouldExitToHome.sink { [weak self] in self?.coordinator.shouldExitToHome = $0 }.store(in: &cancellables)
        $isSessionFinished.sink { [weak self] in self?.coordinator.isSessionFinished = $0 }.store(in: &cancellables)
        $showInstruction.sink { [weak self] in self?.coordinator.showInstruction = $0 }.store(in: &cancellables)
        $isTimeUp.sink { [weak self] in self?.coordinator.isTimeUp = $0 }.store(in: &cancellables)
    }
    
    // MARK: - Actions (delegate to coordinator or sub-ViewModels)
    
    func sendMessage() {
        // Also add to messages array for backward compatibility
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedText.isEmpty {
            messages.append(Message(text: trimmedText, type: roomType.shared.type))
        }
        
        coordinator.inputViewModel.inputText = inputText
        coordinator.inputViewModel.sendMessage()
        inputText = ""
    }
    
    func submitComment(text: String, completion: @escaping () -> Void = {}) {
        guard let idea = selectedIdeaForComment else { return }
        coordinator.inputViewModel.submitComment(ideaId: idea.id, text: text, completion: completion)
    }
    
    func openCommentSheet(for idea: IdeaDTO) {
        coordinator.openCommentSheet(for: idea)
    }
    
    func fetchCommentCounts() async {
        await coordinator.fetchCommentCounts()
    }
    
    func fetchAllComments() async {
        await coordinator.fetchAllComments()
    }
    
    func fetchSummary () async {
        let roundType = coordinator.getCurrentRoundType()
        await coordinator.roundSummaryViewModel.fetchSummary(roundType: roundType)
    }
    
    func analyzeIdeas() async {
        await coordinator.analyzeIdeas()
    }
    
    func navigateToFinalSummary() {
        coordinator.navigateToFinalSummary()
    }
    
    func refreshInsightsFromDatabase() async {
        await coordinator.finalSummaryViewModel.refreshInsightsFromDatabase()
    }
    
    func hostAdvanceToNextRound() {
        coordinator.hostAdvanceToNextRound()
    }
    
    func closeInstruction() {
        coordinator.closeInstruction()
    }
    
    func onTapExtensionButton() {
        coordinator.onTapExtensionButton()
    }
    
    func cleanup() {
        coordinator.cleanup()
    }
    
    // MARK: - Helper Methods
    
    func getGreenTypeId() -> Int64? {
        return coordinator.getGreenTypeId()
    }
    
    func getMessageCardType(for typeId: Int64?) -> MessageCardType {
        return roundManager.getMessageCardType(for: typeId)
    }
}

//
//  SessionCoordinator.swift
//  ADA_C6-sunrice
//
//  Created by Antigravity on 23/01/26.
//  Coordinates session lifecycle, managers, and ViewModels.
//

import Combine
import Foundation
import PostgREST
import Supabase

@MainActor
final class SessionCoordinator: ObservableObject {
    // MARK: - Dependencies
    private let sessionService: SessionServicing
    private let ideaService: IdeaServicing
    private let summaryService: SummaryServicing
    private let insightService: IdeaInsightServicing
    
    // MARK: - Managers
    let roundManager: RoundManager
    private let timerManager: TimerManager
    let ideaManager: IdeaManager
    let summaryManager: SummaryManager
    let insightManager: IdeaInsightManager
    
    // MARK: - Sub-ViewModels
    let inputViewModel: SessionInputViewModel
    let roundSummaryViewModel: RoundSummaryViewModel
    let finalSummaryViewModel: FinalSummaryViewModel
    
    // MARK: - Session State
    let sessionId: Int64
    let isHost: Bool
    
    private var session: SessionDTO?
    private var sequence: SequenceDTO?
    private(set) var currentRound: Int64 = 1
    private(set) var currentTypeId: Int64? = nil
    private(set) var currentUserId: Int64? = nil

    
    // MARK: - Navigation State
    @Published var showRoundSummary: Bool = false
    @Published var showFinalSummary: Bool = false
    @Published var isSessionFinished: Bool = false
    @Published var isTimeUp: Bool = false
    @Published var shouldExitToHome: Bool = false
    
    // MARK: - UI State
    @Published var isLoading: Bool = true
    @Published var deadline: Date = Date()
    @Published var prompt: String = ""
    @Published var roomType: SessionRoom = .fact
    @Published var showInstruction: Bool = true
    
    // MARK: - Comment State
    @Published var selectedIdeaForComment: IdeaDTO? = nil
    @Published var showCommentSheet: Bool = false
    
    // MARK: - Analysis State
    @Published var hasFetchedInsights: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(
        sessionId: Int64,
        isHost: Bool = false,
        sessionService: SessionServicing,
        ideaService: IdeaServicing,
        summaryService: SummaryServicing,
        insightService: IdeaInsightServicing
    ) {
        self.sessionId = sessionId
        self.isHost = isHost
        self.sessionService = sessionService
        self.ideaService = ideaService
        self.summaryService = summaryService
        self.insightService = insightService
        
        // Initialize managers
        self.roundManager = RoundManager(sessionService: sessionService)
        self.timerManager = TimerManager(sessionService: sessionService)
        self.ideaManager = IdeaManager(ideaService: ideaService)
        self.summaryManager = SummaryManager(summaryService: summaryService)
        self.insightManager = IdeaInsightManager(insightService: insightService)
        
        // Initialize sub-ViewModels
        self.inputViewModel = SessionInputViewModel(
            sessionId: sessionId,
            ideaManager: ideaManager,
            roundManager: roundManager
        )
        self.roundSummaryViewModel = RoundSummaryViewModel(
            sessionId: sessionId,
            isHost: isHost,
            summaryManager: summaryManager,
            ideaManager: ideaManager
        )
        self.finalSummaryViewModel = FinalSummaryViewModel(
            sessionId: sessionId,
            insightManager: insightManager
        )
        
        // Set up bidirectional references
        inputViewModel.coordinator = self
        roundSummaryViewModel.coordinator = self
        finalSummaryViewModel.coordinator = self
        
        // Inject TimerManager into managers that need polling
        summaryManager.setTimerManager(timerManager)
        insightManager.setTimerManager(timerManager)
        
        // Setup bindings to propagate manager changes
        setupManagerBindings()
        
        Task {
            await loadSessionData()
        }
    }
    
    // Convenience initializer for default services
    convenience init(sessionId: Int64, isHost: Bool = false) {
        self.init(
            sessionId: sessionId,
            isHost: isHost,
            sessionService: SessionService(client: supabaseManager),
            ideaService: IdeaService(client: supabaseManager),
            summaryService: SummaryService(client: supabaseManager),
            insightService: IdeaInsightService(client: supabaseManager)
        )
    }
    
    // MARK: - Manager Bindings
    
    private func setupManagerBindings() {
        // Propagate IdeaManager changes to trigger view updates
        ideaManager.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
        
        // Propagate SummaryManager changes to trigger view updates
        summaryManager.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
        
        // Propagate IdeaInsightManager changes to trigger view updates
        insightManager.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
    }
    
    // MARK: - Session Loading
    
    private func loadSessionData() async {
        do {
            // Fetch session
            session = try await sessionService.fetchSession(id: sessionId)
            
            guard let session = session, let modeId = session.mode_id else {
                print("Error: Session or mode_id not found")
                return
            }
            
            // Fetch sequence
            sequence = try await sessionService.fetchSequence(modeId: modeId)
            
            guard let sequence = sequence else {
                print("Error: Sequence not found")
                return
            }
            
            // Configure RoundManager with sequence
            roundManager.setSequence(sequence)
            
            // Set prompt
            prompt = session.topic ?? "Session Topic"
            
            // Get current round
            currentRound = session.current_round ?? 1
            
            // Load current round type
            await loadRoundType(round: currentRound)
            
            // Fetch current user ID
            await fetchCurrentUserId()
            
            // Configure input ViewModel
            inputViewModel.configure(typeId: currentTypeId, userId: currentUserId)
            
            // Start timer or polling based on role
            if isHost {
                startHostTimer()
            } else {
                startGuestPolling()
            }
            
            // Start polling for comment counts
            timerManager.startPollingCommentCounts { [weak self] in
                await self?.fetchCommentCounts()
            }
            
            isLoading = false
        } catch {
            print("Error loading session data: \(error)")
        }
    }
    
    private func fetchCurrentUserId() async {
        do {
            struct UserRoleSession: Decodable {
                let user_id: Int64
            }
            
            let response: PostgrestResponse<[UserRoleSession]> = try await supabaseManager
                .from("user_role_sessions")
                .select("user_id")
                .eq("session_id", value: Int(sessionId))
                .limit(1)
                .execute()
            
            if let first = response.value.first {
                currentUserId = first.user_id
                print("Current user ID: \(currentUserId ?? 0)")
            }
        } catch {
            print("Error fetching user ID: \(error)")
        }
    }
    
    // MARK: - Round Management
    
    private func loadRoundType(round: Int64) async {
        guard let session = session else { return }
        
        do {
            let roundInfo = try await roundManager.loadRoundType(round: round, session: session)
            
            // Update state
            currentTypeId = roundInfo.typeId
            roomType = roundInfo.sessionRoom
            deadline = roundInfo.deadline
            isTimeUp = false
            showInstruction = true
            
            // Update input ViewModel
            inputViewModel.configure(typeId: currentTypeId, userId: currentUserId)
            
            // Host: Save deadline to database for guest synchronization
            if isHost {
                do {
                    try await sessionService.updateRoundDeadline(
                        sessionId: sessionId,
                        deadline: deadline
                    )
                    print("⏱️ Host: Deadline saved to database: \(deadline)")
                } catch {
                    print("❌ Error updating deadline: \(error)")
                }
            }
            
            // Fetch ideas from previous rounds (cumulative)
            if currentRound > 1 {
                print("📋 Fetching ALL ideas from previous rounds...")
                try await ideaManager.fetchIdeas(sessionId: sessionId, typeId: nil)
            }
        } catch {
            print("Error loading round type: \(error)")
        }
    }
    
    // MARK: - Timer Management
    
    private func startHostTimer() {
        timerManager.startHostTimer(getDeadline: { [weak self] in
            return self?.deadline ?? Date()
        }) { [weak self] in
            await self?.handleTimeUp()
        }
    }
    
    private func startGuestPolling() {
        // Start deadline timer
        timerManager.startGuestDeadlineTimer(getDeadline: { [weak self] in
            return self?.deadline ?? Date()
        }) { [weak self] in
            await self?.handleTimeUp()
        }
        
        // Start polling for round changes
        timerManager.startPollingRound(sessionId: sessionId, currentRound: currentRound) { [weak self] newRound in
            await self?.handleRoundChange(newRound: newRound)
        }
        
        // Start polling for deadline updates (timer synchronization)
        timerManager.registerPollingAction(id: "deadline_sync") { [weak self] in
            guard let self = self else { return }
            
            do {
                let updatedSession = try await self.sessionService.fetchSession(id: self.sessionId)
                
                if let newDeadline = updatedSession.current_round_deadline {
                    await MainActor.run {
                        // Only update if deadline changed significantly (> 1 second difference)
                        if abs(newDeadline.timeIntervalSince(self.deadline)) > 1 {
                            self.deadline = newDeadline
                            print("⏱️ Guest: Deadline synced to \(newDeadline)")
                        }
                    }
                }
            } catch {
                print("❌ Error fetching deadline: \(error)")
            }
        }
    }
    
    private func handleTimeUp() async {
        isTimeUp = true
        
        // Upload local ideas to database
        await inputViewModel.uploadLocalIdeas()
        
        // Wait for other users to upload
        let waitTime = isHost ? 2 : 3
        try? await Task.sleep(nanoseconds: UInt64(waitTime) * 1_000_000_000)
        
        // Fetch ideas for review screen
        // In comment rounds, fetch green ideas (that have comments)
        // In other rounds, fetch ideas for current round
        let typeIdToFetch = isCommentRound ? roundManager.getGreenTypeId() : currentTypeId
        try? await ideaManager.fetchIdeas(sessionId: sessionId, typeId: typeIdToFetch)
        
        // Show Round Summary screen
        showRoundSummary = true
    }
    
    private func handleRoundChange(newRound: Int64) async {
        // Unregister deadline polling for old round
        timerManager.unregisterPollingAction(id: "deadline_sync")
        
        currentRound = newRound
        showRoundSummary = false
        
        // Clear previous round's summary
        summaryManager.clearSummary()
        
        // Check if session is finished (no more rounds after this one)
        if !roundManager.hasNextRound(after: currentRound - 1) {
            print("📊 Guest: Session finished, no more rounds")
            
            // Small delay to ensure RoundSummaryView dismisses before showing SessionFinishedView
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            
            await MainActor.run {
                isSessionFinished = true
            }
            return
        }
        
        // Load next round
        await loadRoundType(round: currentRound)
        
        // Restart guest timers with new deadline and round (will re-register deadline polling)
        if !isHost {
            startGuestPolling()
        }
    }
    
    // MARK: - Round Advancement (Host)
    
    func hostAdvanceToNextRound() {
        guard isHost else { return }
        
        Task {
            await advanceToNextRound()
        }
    }
    
    private func advanceToNextRound() async {
        showRoundSummary = false
        isTimeUp = false
        
        let nextRound = currentRound + 1
        
        // Always update the database current_round so guests can detect the change
        do {
            try await sessionService.updateCurrentRound(sessionId: sessionId, round: nextRound)
            print("📊 Host: Updated current_round to \(nextRound) in database")
        } catch {
            print("❌ Error updating round: \(error)")
        }
        
        if roundManager.hasNextRound(after: currentRound) {
            currentRound = nextRound
            await loadRoundType(round: currentRound)
            startHostTimer()
        } else {
            print("📊 Host: Session complete!")
            isSessionFinished = true
        }
    }
    
    // MARK: - Comments
    
    func openCommentSheet(for idea: IdeaDTO) {
        selectedIdeaForComment = idea
        showCommentSheet = true
    }
    
    func fetchCommentCounts() async {
        do {
            try await ideaManager.fetchCommentCounts(roundManager: roundManager)
        } catch {
            print("❌ Error fetching comment counts: \(error)")
        }
    }
    
    func fetchAllComments() async {
        do {
            try await ideaManager.fetchComments(roundManager: roundManager)
        } catch {
            print("❌ Error fetching comments: \(error)")
        }
    }
    
    // MARK: - Idea Analysis
    
    func analyzeIdeas() async {
        hasFetchedInsights = true
        
        print("🚀 Starting batch idea analysis...")
        
        await insightManager.analyzeAllIdeas(
            sessionId: Int(sessionId),
            isHost: isHost
        )
    }
    
    func navigateToFinalSummary() {
        showFinalSummary = true
    }
    
    // MARK: - Helper Methods
    
    var isCommentRound: Bool {
        return roundManager.isCommentRound(typeId: currentTypeId)
    }
    
    func getGreenTypeId() -> Int64? {
        return roundManager.getGreenTypeId()
    }
    
    func getMessageCardType(for typeId: Int64?) -> MessageCardType {
        return roundManager.getMessageCardType(for: typeId)
    }
    
    func getCurrentRoundType() -> RoundType? {
        guard let typeId = currentTypeId, let sequence = sequence else { return nil }
        
        switch typeId {
        case sequence.first_round: return .white
        case sequence.second_round: return .green
        case sequence.fourth_round: return .yellow
        case sequence.fifth_round: return .black
        case sequence.sixth_round: return .red
        default: return nil  // Return nil for darkGreen and unknown types
        }
    }
    
    func closeInstruction() {
        showInstruction = false
    }
    
    func onTapExtensionButton() {
        if isHost {
            deadline.addTimeInterval(30)
            
            // Persist to database so guests can synchronize
            Task {
                do {
                    try await sessionService.updateRoundDeadline(
                        sessionId: sessionId,
                        deadline: deadline
                    )
                    print("⏱️ Host: Extended deadline by 30s, saved to database")
                } catch {
                    print("❌ Error extending deadline: \(error)")
                }
            }
        } else {
            // TODO: send request time extension to the host
        }
    }
    
    func exitToHome() {
        shouldExitToHome = true
    }
    
    // MARK: - Cleanup
    
    func cleanup() {
        print("🧹 Cleaning up session resources...")
        
        // Cancel timer if running
        timerManager.cancelAllTimers()
        
        // Clear all data
        ideaManager.clearLocalIdeas()
        summaryManager.clearSummary()
        
        print("✅ Session cleanup complete")
    }
    
    deinit {
        timerManager.cancelAllTimersFromDeinit()
    }
}

//
//  JoinSessionViewModel.swift
//  ADA_C6-sunrice
//
//  Created by Komang Wikananda on 19/11/25.
//

import SwiftUI
import Combine

enum JoinSessionStep: Int, CaseIterable {
    case enterCode = 1
    case enterName
    case lobby
    
    var title: String {
        switch self {
        case .enterCode: return "Join a Session"
        case .enterName: return "Join a Session"
        case .lobby: return "Session Lobby"
        }
    }
}

@MainActor
final class JoinSessionViewModel: ObservableObject {
    private let userService: UserServicing
    private let userRoleService: UserRoleServicing
    private let sessionService: SessionServicing
    private let guestRoleId: Int64 = 2
    @Published var lobbySession: SessionDTO?
    @Published var lobbyMode: ModeDTO?
    @Published var lobbyParticipants: [ParticipantDTO] = []
    
    let codeVM = EnterCodeViewModel()
    let nameVM = EnterNameViewModel()
    
    var currentTitle: String { step.title }
    var code: String { codeVM.sessionCode }
    var onNavigateToSessionRoom: ((Int64, Bool) -> Void)?
    @Published var step: JoinSessionStep = .enterCode
    @Published var isPerformingAction = false
    @Published var errorMessage: String?
    @Published private(set) var currentUser: UserDTO?
    @Published private(set) var currentUserRole: UserRoleDTO?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        userService: UserServicing,
        userRoleService: UserRoleServicing,
        sessionService: SessionServicing
    ) {
        self.userService = userService
        self.userRoleService = userRoleService
        self.sessionService = sessionService
        // Forward changes from child VM to ensure the parent view updates if needed
        codeVM.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
            
        nameVM.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }
    
    @MainActor
    convenience init() {
        self.init(
            userService: UserService(client: supabaseManager),
            userRoleService: UserRoleService(client: supabaseManager),
            sessionService: SessionService(client: supabaseManager)
        )
    }
    
    var isNextButtonDisabled: Bool {
        switch step {
        case .enterCode:
            return !codeVM.isValidCode
        case .enterName:
            return !nameVM.isValid || isPerformingAction
        case .lobby:
            return true
        }
    }
    
    
    func handleBack(dismiss: () -> Void) {
        guard let previous = JoinSessionStep(rawValue: step.rawValue - 1) else {
            dismiss()
            return
        }
        withAnimation { step = previous }
    }
    
    func handleNext() {
        Task { await handleNextAction() }
    }
    
    private func handleNextAction() async {
        switch step {
        case .enterCode:
            let ok = await loadSessionData()
            if ok { advanceToNextStep() }
        case .enterName:
            await persistName()
            advanceToNextStep()
        case .lobby:
            break
        }
    }
    
    private func advanceToNextStep() {
        guard let next = JoinSessionStep(rawValue: step.rawValue + 1) else { return }
        withAnimation { step = next }
        if next == .lobby {
            startPollingParticipants()
        }
    }
    
    private func persistName() async {
        guard nameVM.isValid, !isPerformingAction else { return }
        isPerformingAction = true
        defer { isPerformingAction = false }
        
        do {
            errorMessage = nil
            let userRole = try await prepareUserRole()
            let user = try await userService.createUser(name: nameVM.username)
            currentUser = user
            currentUserRole = try await userRoleService.attach(userId: user.id, toRole: userRole.id)
            
            if let session = lobbySession, let role = currentUserRole {
                _ = try await userRoleService.createUserRoleSession(
                    userId: user.id,
                    roleId: role.role_id,
                    sessionId: session.id
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func prepareUserRole() async throws -> UserRoleDTO {
        if let role = currentUserRole {
            return role
        }
        let created = try await userRoleService.createUserRole(roleId: guestRoleId)
        currentUserRole = created
        return created
    }
    
    func makeParticipants() -> [ParticipantDTO] {
        var baseNames = ["Saskia", "Selena", "Hendy", "Richard"]
        if !nameVM.username.isEmpty {
            baseNames.insert(nameVM.username, at: 0)
        }
        return baseNames.enumerated().map { idx, name in
            ParticipantDTO(
                id: Int64(idx + 1),
                name: name,
                status: 1,
                created_at: nil,
                user_role_sessions: [ParticipantDTO.UserRoleSessionInfo(role_id: idx == 0 ? 1 : 2)]
            )
        }
    }
    
    private func loadSessionData() async -> Bool {
        isPerformingAction = true
        defer { isPerformingAction = false }
        do {
            let session = try await sessionService.fetchSession(token: code)
            lobbySession = session
            if let modeId = session.mode_id {
                lobbyMode = try await sessionService.fetchMode(id: modeId)
            }
            // if lobbyParticipants.isEmpty {
            //     lobbyParticipants = makeParticipants()
            // }
            errorMessage = nil
            return true
        } catch {
            errorMessage = "No session with that code found"
            return false
        }
    }
    
    func makePlaceholderSession() -> SessionDTO {
        SessionDTO(
            id: 0,
            duration_per_round: 300,
            topic: "Session",
            description: "",
            token: code,
            is_token_expired: false,
            started_at: nil,
            ended_at: nil,
            created_at: nil,
            mode_id: nil,
            current_round: 1,
            current_round_deadline: nil
        )
    }
    
    // MARK: - Polling
    private var participantsTask: Task<Void, Never>?
    
    private func startPollingParticipants() {
        participantsTask?.cancel()
        participantsTask = Task {
            while !Task.isCancelled {
                if let sessionId = lobbySession?.id {
                    do {
                        // Fetch participants
                        let participants = try await userRoleService.fetchParticipants(sessionId: sessionId)
                        
                        // Fetch updated session to check if started
                        let updatedSession = try await sessionService.fetchSession(id: sessionId)
                        
                        await MainActor.run {
                            self.lobbyParticipants = participants
                            self.lobbySession = updatedSession
                            
                            // Check if session has started
                            if updatedSession.started_at != nil {
                                // Session started, navigate to session room
                                print("Session started! Navigating to session room...")
                                onNavigateToSessionRoom?(sessionId, false)
                                participantsTask?.cancel()
                            }
                        }
                    } catch {
                        print("Error fetching participants: \(error)")
                    }
                }
                try? await Task.sleep(nanoseconds: 2 * 1_000_000_000) // 2 seconds
            }
        }
    }
    
    deinit {
        participantsTask?.cancel()
    }
}

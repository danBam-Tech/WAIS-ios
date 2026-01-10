//
//  RoomLobbyView.swift
//  ADA_C6-sunrice
//
//  Created by Komang Wikananda on 03/11/25.
//

import SwiftUI

struct SessionLobbyView: View {
    let session: SessionDTO
    let mode: ModeDTO?
    let participants: [ParticipantDTO]
    let isHost: Bool
    
    var sortedParticipants: [ParticipantDTO] {
        participants.sorted { p1, p2 in
            if p1.isHost && !p2.isHost { return true }
            if !p1.isHost && p2.isHost { return false }
            return (p1.name ?? "") < (p2.name ?? "")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ScrollView(.horizontal) {
                LazyHStack (spacing: 16) {
                    ForEach(sortedParticipants, id: \.id) { user in
                        ParticipantBadge(name: user.name ?? "user", isHost: user.isHost)
                    }
                }
                .frame(maxHeight: 72)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 8) {
                Text("Your session space is ready")
                    .font(.titleSM)
                if !isHost {
                    Text("Take a breathe — the host will begin soon.")
                        .font(.bodySM)
                }
            }
            .foregroundColor(AppColor.Primary.gray)
            
            Text("Share the session code below so others can join.")
                .font(.bodySM)
                .italic()
                .foregroundColor(AppColor.Primary.gray)
            
            // Code
            SessionCode(session: session)
            
            // Chosen preset
            SelectedPreset(
                title: mode?.title ?? mode?.name ?? "Preset",
                description: mode?.description ?? "Preset details",
                showStats: true,
                duration: mode?.duration ?? "\(mode?.num_of_rounds ?? mode?.round_count ?? 0) rounds",
                numOfRounds: Int(mode?.num_of_rounds ?? mode?.round_count ?? 0),
                sequence: mode?.sequence ?? []
            )
            
            // Session title
            StaticBoxField(
                title: "Session Title",
                description: session.topic ?? "-",
                isSelected: true
            )
            
            // Additional description
            StaticBoxField(
                title: "Additional Description",
                description: session.description ?? "-",
                isSelected: true
            )
            
            if !isHost {
                Label("Once the session starts, all ideas are shared anonymously", systemImage: "info.circle")
                    .font(.bodySM)
                    .foregroundColor(AppColor.Primary.gray)
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    let session = SessionDTO(
        id: 1,
        duration_per_round: 300,
        topic: "How might we make onboarding more delightful?",
        description: "Let’s find creative ways to boost user engagement without adding extra steps.",
        token: "244831",
        is_token_expired: false,
        started_at: nil,
        ended_at: nil,
        created_at: Date(),
        mode_id: 1,
        current_round: 1,
        current_round_deadline: nil
    )
    let mode = ModeDTO(
        id: 1,
        name: "Quick Feedback",
        created_at: nil,
        round_count: 3,
        title: "Quick Feedback",
        description: "A short, balanced rhythm for fast reflection",
        duration: "30 min",
        num_of_rounds: 3,
        sequence: ["y", "b", "r"],
        overview: nil,
        best_for: nil,
        outcome: nil,
        status: .coming_soon
    )
    let participants = [
        ParticipantDTO(id: 1, name: "Saskia", status: 1, created_at: nil, user_role_sessions: [.init(role_id: 1)]),
        ParticipantDTO(id: 2, name: "Selena", status: 1, created_at: nil, user_role_sessions: [.init(role_id: 2)])
    ]
    SessionLobbyView(session: session, mode: mode, participants: participants, isHost: true)
}

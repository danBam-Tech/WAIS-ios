//
//  ReviewSessionView.swift
//  ADA_C6-sunrice
//
//  Created by Komang Wikananda on 17/11/25.
//

import SwiftUI

struct ReviewSessionView: View {
    @ObservedObject var vm: CreateSessionViewModel
    
    var body: some View {
        VStack (alignment: .leading, spacing: 16) {
            // Title
            Text("Review and start your session")
                .font(.titleSM)
                .foregroundColor(AppColor.Primary.gray)
            
            // Chosen presets
            if let preset = vm.selectedPreset {
                SelectedPreset(
                    title: preset.title,
                    description: preset.description,
                    showStats: false,
                    numOfRounds: preset.numOfRounds,
                    sequence: preset.sequence
                )
            }
            
            // Select duration
            DurationSelector(durationPerRound: $vm.durationPerRound)
            Text("Shorter rounds keep energy high; you can always add more time during the session.")
                .font(.bodySM)
                .foregroundColor(AppColor.grayscale40)
            
            VStack(alignment: .leading, spacing: 8) {
                Label("About Private Mode", systemImage: "info.circle")
                    .font(.labelMD)
                Text("Anonymity is always on — names will disappear once the session begins.")
                    .font(.bodySM)
            }
            .foregroundColor(AppColor.Primary.gray)
        }
    }
}

#Preview {
    ReviewSessionView(vm: CreateSessionViewModel(socketManager: WebSocketManager()))
}

//
//  ChoosePresetView.swift
//  ADA_C6-sunrice
//
//  Created by Komang Wikananda on 17/11/25.
//

import SwiftUI

struct SelectPresetView: View {
    @ObservedObject var vm: CreateSessionViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Title
            VStack(alignment: .leading, spacing: 8) {
                Text("Pick a color flow for your session")
                    .font(.titleSM)
                    .foregroundColor(AppColor.Primary.gray)
                Text("Each flow shapes how your team will explore ideas. You can start simple — more strategies will arrive soon.")
                    .font(.bodySM)
                    .foregroundColor(AppColor.Primary.gray)
            }
            
            // Presets
            VStack(alignment: .leading, spacing: 16) {
                if vm.isLoadingPresets {
                    ProgressView("Loading presets...")
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    ForEach(vm.presets) { preset in
                        Presets(
                            title: preset.title,
                            description: preset.description,
                            duration: preset.duration,
                            numOfRounds: preset.numOfRounds,
                            sequence: preset.sequence,
                            overview: preset.overview,
                            bestFor: preset.bestFor,
                            outcome: preset.outcome,
                            isSelected: vm.selectedPreset?.id == preset.id,
                            onSelect: {
                                if vm.selectedPreset?.id != preset.id {
                                    vm.selectedPreset = preset
                                }
                            }
                        )
                        .animation(.easeInOut(duration: 0.1), value: vm.selectedPreset)
                        .disabled(preset.id == 1)
                    }
                }
                
                ForEach(vm.tbaPresets) { preset in
                    TBAPreset(title: preset.title)
                }
            }
        }
    }
}

#Preview {
    SelectPresetView(vm: CreateSessionViewModel(socketManager: WebSocketManager()))
}

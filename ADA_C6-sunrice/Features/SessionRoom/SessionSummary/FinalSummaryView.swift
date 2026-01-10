//
//  FinalSummaryView.swift
//  ADA_C6-sunrice
//
//  Created by Antigravity on 27/11/25.
//

import SwiftUI

struct FinalSummaryView: View {
    @ObservedObject var vm: SessionRoomViewModel
    @EnvironmentObject var navVM: NavigationViewModel
    @State private var showExitAlert = false
    @State private var didRefresh = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Header(
                config: .init(
                    title: "Session Summary",
                    showsBackButton: false,
                    trailing: .none
                )
            )
            .padding(.horizontal)
            .padding(.bottom, 16)
            
            // Summary Content
            ScrollView {
                VStack(spacing: 24) {
                    SummarySessionCard(vm: vm)
                        .padding(.horizontal, 16)
                    
                    Spacer(minLength: 100)
                }
                .padding(.top, 16)
            }
            
            // Bottom Button
            VStack(spacing: 0) {
                AppButton(title: "Go to Lobby") {
                    showExitAlert = true
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .background(Background())
        .interactiveDismissDisabled(true)
        .task {
            guard !didRefresh else { return }
            didRefresh = true
            await vm.refreshInsightsFromDatabase()
        }
        .alert("Go to Lobby Now?", isPresented: $showExitAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Go to Lobby", role: .destructive) {
                vm.cleanup()
                Task {
                    try? await Task.sleep(nanoseconds: 100_000_000)
                    await MainActor.run {
                        navVM.popToRoot()
                    }
                }
            }
        } message: {
            Text("You will return to the home screen.")
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .onTapToDismissKeyboard()
    }
}

#Preview {
    FinalSummaryView(vm: SessionRoomViewModel(id: 1))
}

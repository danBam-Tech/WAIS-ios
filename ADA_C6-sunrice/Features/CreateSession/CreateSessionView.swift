//
//  CreateSessionView.swift
//  ADA_C6-sunrice
//
//  Created by Komang Wikananda on 19/11/25.
//

import SwiftUI

struct CreateSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navVM: NavigationViewModel
    @StateObject private var vm = CreateSessionViewModel()
    @State private var alertDismissTask: Task<Void, Never>?
    @State private var showStartSessionAlert = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                Header(
                    config: .init(title: vm.currentTitle),
                    onBack: { vm.handleBack(dismiss: { dismiss() }) }
                )
                
                if (vm.step.rawValue > 1 && vm.step.rawValue < 5) {
                    Stepper(totalSteps: 3, currentSteps: vm.step.rawValue - 1, horizontalPadding: 24)
                        .frame(height: 24)
                }
                
                GeometryReader { proxy in
                    ScrollView {
                        stepContent
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: proxy.size.height, alignment: .top)
                    }
                    .onTapGesture {
                        UIApplication.shared.endEditing()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                AppButton(title: vm.buttonText) {
                    // Show confirmation alert only for lobby step
                    if vm.step == .lobby {
                        showStartSessionAlert = true
                    } else {
                        vm.handleNext()
                    }
                }
                .disabled(vm.isNextButtonDisabled)
            }
            
            if let message = vm.errorMessage {
                AlertMessage(message: message)
                    .offset(y: -75)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                if value.translation.height > 24 {
                                    withAnimation {
                                        vm.errorMessage = nil
                                    }
                                }
                            }
                    )
            }
            
        }
        .padding(.horizontal)
        .padding(.bottom)
        .animation(.spring(), value: vm.errorMessage)
        .onChange(of: vm.errorMessage) { newValue in
            alertDismissTask?.cancel()
            guard let message = newValue else { return }
            
            alertDismissTask = Task {
                try? await Task.sleep(for: .seconds(3))
                await MainActor.run {
                    if vm.errorMessage == message {
                        withAnimation {
                            vm.errorMessage = nil
                        }
                    }
                }
            }
        }
        .onDisappear {
            alertDismissTask?.cancel()
        }
        .onAppear {
            vm.onNavigateToSessionRoom = { sessionId, isHost in
                navVM.goToSessionRoom(id: sessionId, isHost: isHost)
            }
        }
        .alert("Start Session?", isPresented: $showStartSessionAlert) {
            Button("Wait a minute", role: .destructive) { }
            Button("Start Session", role: .cancel) {
                vm.handleNext()
            }
        } message: {
            Text("Once started, participants can begin sharing ideas. Make sure everyone who wants to join is in the lobby.")
        }
        
    }
    
    @ViewBuilder
    private var stepContent: some View {
        switch vm.step {
        case .enterName:
            EnterNameView(vm: vm.nameVM)
        case .defineSession:
            DefineSessionView(vm: vm)
        case .selectPreset:
            SelectPresetView(vm: vm)
        case .reviewSession:
            ReviewSessionView(vm: vm)
        default:
            if let session = vm.lobbySession {
                SessionLobbyView(
                    session: session,
                    mode: vm.lobbyMode,
                    participants: vm.lobbyParticipants,
                    isHost: true
                )
            }
        }
    }
}

#Preview {
    CreateSessionView()
}

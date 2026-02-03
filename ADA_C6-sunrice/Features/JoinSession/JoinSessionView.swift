//
//  JoinSessionView.swift
//  ADA_C6-sunrice
//
//  Created by Komang Wikananda on 15/11/25.
//

import SwiftUI

struct JoinSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navVM: NavigationViewModel
    @StateObject private var vm: JoinSessionViewModel
    @State private var alertDismissTask: Task<Void, Never>?
    
    init(socketManager: WebSocketManager) {
        _vm = StateObject(
            wrappedValue: JoinSessionViewModel(socketManager: socketManager)
        )
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 24) {
                Header(
                    config: .init(title: vm.currentTitle),
                    onBack: { vm.handleBack(dismiss: { dismiss() }) }
                )
                
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
                
                if (vm.step != .lobby) {
                    AppButton(title: "Continue") {
                        vm.handleNext()
                    }
                    .disabled(vm.isNextButtonDisabled)
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            
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
        .animation(.easeInOut, value: vm.step)
        .animation(.spring(), value: vm.errorMessage)
        .onChange(of: vm.errorMessage) { newValue in
            alertDismissTask?.cancel()
            guard let message = newValue else { return }
            
            alertDismissTask = Task {
                try? await Task.sleep(for: .seconds(3))
                await MainActor.run {
                    if vm.errorMessage == message {
                        vm.errorMessage = nil
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
    }
    
    @ViewBuilder
    private var stepContent: some View {
        switch vm.step {
        case .enterCode:
            EnterCodeView(vm: vm.codeVM)
        case .enterName:
            EnterNameView(vm: vm.nameVM)
        case .lobby:
            SessionLobbyView(
                session: vm.lobbySession ?? vm.makePlaceholderSession(),
                mode: vm.lobbyMode,
                participants: vm.lobbyParticipants.isEmpty ? vm.makeParticipants() : vm.lobbyParticipants,
                isHost: false
            )
        }
    }
}

#Preview {
    JoinSessionView(socketManager: WebSocketManager())
}

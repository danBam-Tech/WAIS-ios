//
//  SessionRoomView.swift
//  ADA_C6-sunrice
//
//  Created by Selena Aura on 10/11/25.
//

import SwiftUI

struct SessionRoomView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navVM: NavigationViewModel

    @StateObject private var vm: SessionRoomViewModel
    @State private var showExitAlert = false

    init(id: Int64, isHost: Bool = false) {
        _vm = .init(wrappedValue: .init(id: id, isHost: isHost))
    }

    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        if vm.isLoading {
//            ProgressView("Loading session...")
            PreparingLoadingScreen()
        } else {
            sessionContent
        }
    }
    
    private var sessionContent: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 8) {
                Header(
                    config: .init(
                        title: vm.roomType.shared.title,
                        showsBackButton: true,
                        trailing: .timer(date: vm.deadline)
                    ),
                    onBack: { showExitAlert = true }
                )
                .padding(.horizontal)
                .padding(.bottom, 4)

                // Prompt
                RoomPrompt(title: vm.prompt)

                // Messages area
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .trailing, spacing: 8) {
                            // Show ideas from previous rounds (from all users)
                            ForEach(vm.serverIdeas) { idea in
                                 let isGreenIdea = idea.type_id == vm.getGreenTypeId()
                                 let showPlus = vm.isCommentRound && isGreenIdea
                                 
                                 let counts = vm.commentCounts[idea.id] ?? CommentCounts(yellow: 0, black: 0, darkGreen: 0)
                                 
                                 IdeaBubbleView(
                                     text: idea.text ?? "",
                                     type: vm.getMessageCardType(for: idea.type_id),
                                     ideaId: Int(idea.id),
                                     yellowMessages: counts.yellow,
                                     blackMessages: counts.black,
                                     darkGreenMessages: counts.darkGreen,
                                     showPlusButton: showPlus,
                                     onTapPlus: { _ in
                                         vm.openCommentSheet(for: idea)
                                     }
                                 )
                                 .padding(.horizontal, 16)
                            }
                            
                            // Show current round's local ideas (not yet uploaded)
                            ForEach(Array(vm.localIdeas.enumerated()), id: \.offset) { index, localIdea in
                                IdeaBubbleView(
                                    text: localIdea.text,
                                    type: vm.roomType.shared.type,
                                    ideaId: index
                                )
                                .padding(.horizontal, 16)
                                .id("local-\(index)")
                            }
                            
                            Color.clear
                                .frame(maxWidth: .infinity)
                                .frame(height: 125)
                        }
                        .padding(.vertical, 8)
                    }
                    .onTapGesture {
                        UIApplication.shared.endEditing()
                    }
                    .onChange(of: vm.localIdeas.count, initial: true) { _, _ in
                        // Scroll to last local idea when new one is added
                        if !vm.localIdeas.isEmpty {
                            withAnimation {
                                proxy.scrollTo("local-\(vm.localIdeas.count - 1)", anchor: .bottom)
                            }
                        }
                    }
                }
            }

            VStack(alignment: .trailing, spacing: 0) {
                // Time extension button
                MoreTimeButton(
                    isHost: vm.isHost,
                    action: vm.onTapExtensionButton
                )

                // Input area - only show in non-comment rounds
                if !vm.isCommentRound {
                    InputArea(inputText: $vm.inputText, action: vm.sendMessage)
                } else {
                    // In comment rounds, show instruction to tap plus button
                    HStack {
                        Image(systemName: "info.circle")
                        Text("Tap the + button on ideas to add comments")
                            .font(.bodySM)
                    }
                    .foregroundColor(AppColor.Primary.gray)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppColor.blue10)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
        }
        .onTapToDismissKeyboard()
        .overlay(alignment: .center) {
            if vm.showInstruction {
                InstructionCard(
                    instruction: vm.roomType.shared.instruction,
                    onTap: vm.closeInstruction
                )
            }
            // TODO: finish logic; implement current & total players
//            if vm.showIntroduction {
//                SessionIntroductionView(introduction: vm.roomType.shared.introduction)
//            }
            if vm.isSessionFinished {
                SessionFinishedView(vm: vm)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.5), value: vm.isSessionFinished)
            } else if vm.isTimeUp {
                TimesUpView()
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.5), value: vm.isTimeUp)
            }
        }
        .fullScreenCover(isPresented: $vm.showRoundSummary) {
            RoundSummaryView(vm: vm)
        }
        .sheet(isPresented: $vm.showCommentSheet) {
            CommentSheetView(vm: vm)
        }
        .fullScreenCover(isPresented: $vm.showFinalSummary) {
            FinalSummaryView(vm: vm)
                .environmentObject(navVM)
        }
        .onChange(of: vm.isTimeUp) { _, timeUp in
            if timeUp {
                // Dismiss keyboard
                UIApplication.shared.endEditing()
                // Close any open sheets
                vm.showCommentSheet = false
                // Unfocus text field
                isTextFieldFocused = false
            }
        }
        .onChange(of: vm.shouldExitToHome) { _, shouldExit in
            if shouldExit {
                Task {
                    try? await Task.sleep(nanoseconds: 100_000_000)
                    await MainActor.run {
                        navVM.popToRoot()
                    }
                }
            }
        }
        .alert("Leave Session?", isPresented: $showExitAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Leave", role: .destructive) {
                vm.cleanup()
                Task {
                    // Small delay to allow alert to dismiss first
                    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                    await MainActor.run {
                        navVM.popToRoot()
                    }
                }
            }
        } message: {
            Text("Are you sure you want to leave this session? You'll return to the home screen.")
        }
    }
}

#Preview {
    SessionRoomView(id: 1)
}

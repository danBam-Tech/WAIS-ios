//
//  RoundSummaryView.swift
//  ADA_C6-sunrice
//
//  Created by Antigravity on 24/11/25.
//

import SwiftUI

struct RoundSummaryView: View {
    @ObservedObject var vm: SessionRoomViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var hasFetchedData = false
    @State private var showExitAlert = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                Header(
                    config: .init(
                        title: vm.roomType.shared.title,
                        showsBackButton: true,
                        trailing: .none
                    ),
                    onBack: { showExitAlert = true }
                )
                .padding(.horizontal)
                
                // Prompt
                RoomPrompt(title: vm.prompt)
                
                // Ideas List
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        // Show green ideas if in comment round, otherwise show current round ideas
                        
                        // Show comments for this round (in comment rounds)
                        if vm.isCommentRound {
                            let commentsForRound = vm.serverComments.filter { $0.type_id == vm.currentTypeId }
                            ForEach(commentsForRound, id: \.id) { comment in
                                IdeaBubbleView(
                                    text: comment.text ?? "",
                                    type: vm.getMessageCardType(for: comment.type_id),
                                    ideaId: Int(comment.id)
                                )
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 16)
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 12) {
                                if vm.isLoadingSummary || (vm.summary == nil && vm.summaryError == nil) {
                                    HStack(spacing: 12) {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
                                        Text("Waiting for AI summary...")
                                            .font(.bodySM)
                                            .foregroundColor(AppColor.Primary.gray)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(AppColor.blue10)
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                                } else if let error = vm.summaryError {
                                    // Error state
                                    if vm.isHost {
                                        // Host: Show error with retry button
                                        VStack(spacing: 12) {
                                            HStack(spacing: 8) {
                                                Image(systemName: "exclamationmark.triangle.fill")
                                                    .foregroundColor(.red)
                                                Text("Failed to generate summary")
                                                    .font(.titleSSM)
                                                    .foregroundColor(AppColor.Primary.gray)
                                            }
                                            
//                                            Text(error)
//                                                .font(.bodySM)
//                                                .foregroundColor(AppColor.grayscale40)
//                                                .multilineTextAlignment(.center)
                                            
                                            Button {
                                                Task {
                                                    await vm.fetchSummary()
                                                }
                                            } label: {
                                                Label("Retry", systemImage: "arrow.clockwise")
                                                    .font(.bodySM)
                                                    .fontWeight(.semibold)
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 8)
                                                    .background(AppColor.Primary.blue)
                                                    .foregroundColor(.white)
                                                    .cornerRadius(8)
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.red.opacity(0.1))
                                        .cornerRadius(12)
                                        .padding(.horizontal)
                                    } else {
                                        // Guest: Keep showing loading (polling continues in background)
                                        HStack(spacing: 12) {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle())
                                            Text("Waiting for AI summary...")
                                                .font(.bodySM)
                                                .foregroundColor(AppColor.Primary.gray)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(AppColor.blue10)
                                        .cornerRadius(12)
                                        .padding(.horizontal)
                                    }
                                } else if let summary = vm.summary {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("AI Summary")
                                            .font(.titleSM)
                                            .foregroundColor(AppColor.Primary.gray)
                                            .padding(.horizontal)
                                        
                                        // Notes
                                        if let notes = summary.notes, !notes.isEmpty {
                                            Text(notes)
                                                .font(.bodySM)
                                                .foregroundColor(AppColor.Primary.gray)
                                                .padding(.horizontal)
                                        }
                                        
                                        // Insight Categories using the new card view
                                        let categories = summary.themes.map { theme in
                                            InsightCategory(
                                                title: theme.name,
                                                body: theme.summary,
                                                sources: theme.items?.map { $0.input } ?? []
                                            )
                                        }
                                        
                                        InsightCategoryListCard(items: categories, type: vm.getMessageCardType(for: vm.currentTypeId))
                                    }
                                }
                            }
                            // Button to navigate to all cards view
                            NavigationLink(destination: AllCardsView(vm: vm)) {
                                ButtonSeeAllCards()
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.vertical, 8)
//                    // AI Summary Section (for white, green, red rounds)
//                    if !vm.isCommentRound {
//                        
//                    }
                }
                
                Spacer()
                
                // Bottom Action
                if vm.isHost {
                    // Host: Next Round button
                    AppButton(title: "Next Round") {
                        vm.hostAdvanceToNextRound()
                    }
                    .padding(.horizontal)
                } else {
                    // Guest: Waiting message
                    HStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                        Text("Waiting for host to start next round...")
                            .font(.bodySM)
                            .foregroundColor(AppColor.Primary.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColor.blue10)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Background()
            )
            .onAppear {
                // Only fetch data once
                guard !hasFetchedData else { return }
                hasFetchedData = true
                
                Task {
                    // Fetch comment counts
                    await vm.fetchCommentCounts()
                    
                    // If it's a comment round, also fetch the actual comments
                    if vm.isCommentRound {
                        await vm.fetchAllComments()
                    } else {
                        // For non-comment rounds (white, green, red), fetch AI summary
                        await vm.fetchSummary()
                    }
                }
            }
            .padding(.bottom)
            .alert("Leave Session?", isPresented: $showExitAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Leave", role: .destructive) {
                    // Call cleanup and signal to exit to home
                    vm.cleanup()
                    vm.shouldExitToHome = true
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to leave this session? You'll return to the home screen.")
            }
        }
    }
}
    
#Preview {
    struct PreviewWrapper: View {
        @StateObject var vm: SessionRoomViewModel
        
        init() {
            _vm = StateObject(wrappedValue: SessionRoomViewModel(id: 1, isHost: true))
        }
        
        var body: some View {
            RoundSummaryView(vm: vm)
        }
    }
    
    return PreviewWrapper()
}


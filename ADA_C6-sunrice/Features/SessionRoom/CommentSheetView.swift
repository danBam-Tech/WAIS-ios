//
//  CommentSheetView.swift
//  ADA_C6-sunrice
//
//  Created by Antigravity on 24/11/25.
//

import SwiftUI

struct CommentSheetView: View {
    @ObservedObject var vm: SessionRoomViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var commentText: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var existingComments: [IdeaCommentDTO] = []
    @State private var isLoadingComments: Bool = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Scrollable area for original idea and existing comments
                ScrollView {
                    VStack(alignment: .trailing, spacing: 16) {
                        // Original Idea
                        if let idea = vm.selectedIdeaForComment {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Original Idea")
                                    .font(.labelMD)
                                    .foregroundColor(AppColor.Primary.gray)
                                
                                IdeaBubbleView(
                                    text: idea.text ?? "",
                                    type: .green,
                                    ideaId: Int(idea.id)
                                )
                            }
                            .padding(.horizontal)
                            .padding(.top)
                        }
                        
                        // Existing Comments
                        if isLoadingComments {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else if !existingComments.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(existingComments) { comment in
                                    IdeaBubbleView(
                                        text: comment.text ?? "",
                                        type: vm.getMessageCardType(for: comment.type_id),
                                        ideaId: Int(comment.id)
                                    )
                                    .frame(maxWidth: 335)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .onTapGesture {
                    UIApplication.shared.endEditing()
                }
                
                Divider()
                
                // Input area at bottom
                VStack(spacing: 12) {
                    InputArea(inputText: $commentText, action: submitComment)
                }
                .ignoresSafeArea()
            }
            .onTapToDismissKeyboard()
            .navigationTitle(vm.roomType.shared.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadExistingComments()
                isTextFieldFocused = true
            }
        }
    }
    
    private func loadExistingComments() {
        guard let idea = vm.selectedIdeaForComment else { return }
        
        Task {
            do {
                let comments = try await vm.ideaService.fetchCommentsForIdeas(ideaIds: [idea.id])
                await MainActor.run {
                    existingComments = comments
                    isLoadingComments = false
                }
            } catch {
                print("Error loading comments: \(error)")
                await MainActor.run {
                    isLoadingComments = false
                }
            }
        }
    }
    
    private func submitComment() {
        vm.submitComment(text: commentText) {
            // Clear text and reload comments on success
            commentText = ""
            loadExistingComments()
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
            CommentSheetView(vm: vm)
        }
    }
    
    return PreviewWrapper()
}

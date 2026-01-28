//
//  SessionInputViewModel.swift
//  ADA_C6-sunrice
//
//  Created by Antigravity on 23/01/26.
//  Extracted from SessionRoomViewModel for better separation of concerns.
//

import Foundation
import Combine

@MainActor
final class SessionInputViewModel: ObservableObject {
    // MARK: - Dependencies
    private let ideaManager: IdeaManager
    private let roundManager: RoundManager
    weak var coordinator: SessionCoordinator?
    
    // MARK: - Published State
    @Published var inputText: String = ""
    @Published var isSendingMessage: Bool = false
    
    // MARK: - Private State
    private var currentTypeId: Int64?
    private var currentUserId: Int64?
    private let sessionId: Int64
    
    // MARK: - Initialization
    
    init(sessionId: Int64, ideaManager: IdeaManager, roundManager: RoundManager) {
        self.sessionId = sessionId
        self.ideaManager = ideaManager
        self.roundManager = roundManager
    }
    
    // MARK: - Configuration
    
    func configure(typeId: Int64?, userId: Int64?) {
        self.currentTypeId = typeId
        self.currentUserId = userId
    }
    
    // MARK: - Message/Idea Sending
    
    func sendMessage() {
        guard let typeId = currentTypeId else {
            print("❌ Cannot send message: no typeId")
            return
        }
        guard !isSendingMessage else {
            print("⏸️ Already sending message, ignoring")
            return
        }
        
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            print("⏸️ Empty message, ignoring")
            return
        }
        
        // Set sending state
        isSendingMessage = true
        
        // Add the idea locally
        ideaManager.addLocalIdea(text: trimmedText, typeId: typeId)
        
        // Clear input
        inputText = ""
        
        // Reset sending state
        isSendingMessage = false
    }
    
    // MARK: - Comment Submission
    
    func submitComment(ideaId: Int64, text: String, completion: @escaping () -> Void = {}) {
        guard let typeId = currentTypeId else {
            print("❌ Cannot submit comment: no typeId")
            return
        }
        guard let userId = currentUserId else {
            print("❌ Cannot submit comment: no userId")
            return
        }
        guard !isSendingMessage else {
            print("⏸️ Already sending comment, ignoring")
            return
        }
        
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            print("⏸️ Empty comment, ignoring")
            return
        }
        
        isSendingMessage = true
        
        Task {
            do {
                try await ideaManager.submitComment(
                    ideaId: ideaId,
                    text: trimmedText,
                    typeId: typeId,
                    userId: userId
                )
                
                // Refresh comment counts
                try await ideaManager.fetchCommentCounts(roundManager: roundManager)
                
                await MainActor.run {
                    completion()
                }
            } catch {
                print("❌ Error submitting comment: \(error)")
            }
            
            // Reset sending state
            await MainActor.run {
                isSendingMessage = false
            }
        }
    }
    
    // MARK: - Idea Upload
    
    func uploadLocalIdeas() async {
        guard let userId = currentUserId else {
            print("❌ Error: User ID not found for upload")
            return
        }
        
        do {
            try await ideaManager.uploadLocalIdeas(sessionId: sessionId, userId: userId)
        } catch {
            print("❌ Error uploading ideas: \(error)")
        }
    }
}

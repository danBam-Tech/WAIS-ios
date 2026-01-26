//
//  SummarySessionCard.swift
//  ADA_C6-sunrice
//
//  Created by Saskia on 25/11/25.
//

import SwiftUI

// MARK: - LIVE VIEW

/// Summary card shown at the end of the session.
/// Uses real data from IdeaManager + RoundManager + IdeaInsightManager.
struct SummarySessionCard: View {
    @ObservedObject var vm: SessionRoomViewModel
    
    @State private var summaryText: String = ""
    @State private var didLoad = false
    @State private var isLoadingSummary = false
    @State private var summaryError: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            // Summary paragraph
            if isLoadingSummary {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Generating final summary...")
                        .font(.bodySM)
                        .foregroundColor(.secondary)
                }
            } else if let error = summaryError {
                if vm.isHost {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text("Failed to generate summary")
                                .font(.bodySM)
                                .foregroundColor(.red)
                        }
                        
                        Button {
                            Task {
                                await loadFinalSummary()
                            }
                        } label: {
                            Label("Retry", systemImage: "arrow.clockwise")
                                .font(.bodySM)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(AppColor.Primary.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                } else {
                    Text("Waiting for summary...")
                        .font(.bodySM)
                        .foregroundColor(.secondary)
                }
            } else if !summaryText.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Session Summary")
                        .font(.labelMD)
                        .foregroundColor(.primary)
                    
                    Text(summaryText)
                        .font(.bodySM)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            // "Ideas:" title
            Text("Ideas:")
                .font(.labelMD)
                .foregroundColor(.primary)
            
            // List of idea insights
            VStack(spacing: 16) {
                ForEach(vm.ideaInsights) { insight in
                    IdeaSummaryCard(
                        ideaText: getIdeaText(for: insight.ideaId),
                        ratingString: insight.rating,
                        why: insight.why,
                        evidence: insight.evidence,
                        commentCounts: vm.commentCounts[insight.ideaId]
                    )
                }
            }
        }
        .padding(16)
        .frame(width: 360, alignment: .topLeading)
        .background(Color.grayscale10)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .inset(by: 0.5)
                .stroke(Color.grayscale20, lineWidth: 1)
        )
        .task {
            guard !didLoad else { return }
            didLoad = true
            await loadSummaryData()
            await loadFinalSummary()
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .onTapToDismissKeyboard()
    }
    
    // MARK: - Data helpers
    
    /// Get idea text by ID
    private func getIdeaText(for ideaId: Int64) -> String {
        vm.serverIdeas.first { $0.id == ideaId }?.text ?? "Unknown idea"
    }
    
    /// Fetches ideas + comment counts (benefit/risk/build-on) from backend.
    private func loadSummaryData() async {
        do {
            try await vm.ideaManager.fetchIdeas(
                sessionId: vm.sessionId,
                typeId: vm.getGreenTypeId()
            )
            try await vm.ideaManager.fetchCommentCounts(roundManager: vm.roundManager)
            try await vm.ideaManager.fetchComments(roundManager: vm.roundManager)
        } catch {
            print("⚠️ Failed to load summary data: \(error)")
        }
    }
    
    /// Generate and fetch final summary
    private func loadFinalSummary() async {
        isLoadingSummary = true
        summaryError = nil
        defer { isLoadingSummary = false }
        
        do {
            // First try to fetch existing summary
            if let existing = try await vm.summaryManager.summaryService.fetchFinalSummary(sessionId: Int(vm.sessionId)) {
                summaryText = existing.summaryText
                print("✅ Loaded existing final summary")
                return
            }
            
            // If not found, generate new one (only host should do this ideally)
            print("📝 Generating new final summary...")
            let response = try await vm.summaryManager.summaryService.generateFinalSummary(sessionId: Int(vm.sessionId))
            
            if response.success {
                summaryText = response.summary.summaryText
                print("✅ Generated final summary")
            } else {
                summaryError = "Failed to generate summary"
            }
        } catch {
            print("❌ Error loading final summary: \(error)")
            summaryError = "Failed to generate summary"
        }
    }
}


// MARK: - PREVIEW SUPPORT (UI-only, no backend)

// Simple local model just for preview
struct FakeIdea: Identifiable {
    let id = UUID()
    let text: String
    let counts: CommentCounts
}

/// A static version of the card used only for previewing the UI.
/// It recreates the same layout as `SummarySessionCard` but with local data.
struct SummarySessionCardPreviewContent: View {
    private let summaryText: String =
    """
    Learners are mostly new to the academy, unfamiliar with CBL and app development. Many don't know what to expect, what they want to learn, or their desired role.

    Challenges include team dynamics and varied mentor styles. There's a desire for clear guidance and community support. Learners are confused and sometimes feel rushed, but value the positive learning environment.
    """
    
    private let ideas: [FakeIdea] = [
        FakeIdea(
            text: "Short videos within categorised playlist on ADA essential informations",
            counts: CommentCounts(yellow: 0, black: 0, darkGreen: 0)   // Neutral
        ),
        FakeIdea(
            text: "Guidebook on who's who and their expertise and how they can help",
            counts: CommentCounts(yellow: 1, black: 3, darkGreen: 0)   // Risky
        ),
        FakeIdea(
            text: "Make some material they could read to prepare a bit on how to get into CBL process",
            counts: CommentCounts(yellow: 4, black: 1, darkGreen: 0)   // Good
        )
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(summaryText)
                .font(.system(size: 12))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("Ideas:")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
            
            VStack(spacing: 16) {
                ForEach(ideas) { idea in
//                    IdeaSummaryCard(
//                        ideaText: idea.text,
//                        commentCounts: idea.counts
//
//                    )
                }
            }
        }
        .padding(16)
        .frame(width: 360, alignment: .topLeading)
        .background(Color.grayscale10)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .inset(by: 0.5)
                .stroke(Color.grayscale20, lineWidth: 1)
        )
    }
}


// MARK: - PreviewProvider

struct SummarySessionCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            SummarySessionCardPreviewContent()
                .padding(.vertical, 40)
        }
        .previewLayout(.sizeThatFits)
    }
}

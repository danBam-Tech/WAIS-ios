//
//  IdeaSummaryCard.swift
//  ADA_C6-sunrice
//
//  Created by Saskia on 25/11/25.
//

import SwiftUI

/// 3-level rating based on benefits vs risks
enum IdeaRating {
    case neutral
    case good
    case risky
    
    var label: String {
        switch self {
        case .neutral: return "Neutral"
        case .good:    return "Good"
        case .risky:   return "Risky"
        }
    }
    
    var pillBackground: Color {
        switch self {
        case .neutral:
            return Color.whiteishBlue10
        case .good:
            return Color.green10
        case .risky:
            return Color.red10
        }
    }
    
    var pillTextColor: Color {
        switch self {
        case .neutral:
            return Color.whiteishBlue70
        case .good:
            return Color.green50
        case .risky:
            return Color.red
        }
    }
}

struct IdeaSummaryCard: View {
    let ideaText: String
    let ratingString: String  // From database: "good", "neutral", "risky"
    let why: String
    let evidence: IdeaInsightEvidence
    let commentCounts: CommentCounts?
    
    @State private var showDetail = false
    
    var body: some View {
        HStack(spacing: 0) {
            // LEFT GREEN BOOKMARK
            Rectangle()
                .fill(Color.green50)
                .frame(width: 16)
                .frame(maxHeight: .infinity)
            
            // CONTENT
            VStack(alignment: .leading, spacing: 8) {
                Text(ideaText)
                    .font(Font.custom("SF Pro", size: 12))
                    .foregroundColor(Color.grayscale60)
                    .frame(alignment: .leading)
                    .multilineTextAlignment(.leading)
                
                // Bottom row: Rating label + pill
                HStack(spacing: 6) {
                    Text("Rating:")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color.grayscale50)

                    ratingPill(for: convertedRating)
                    
                    Spacer(minLength: 0)
                }
            }
            .padding(16)
        }
        .background(Color.grayscale10)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.grayscale20, lineWidth: 1)
        )
        // 🔹 Chevron overlay, vertically centered in the card
        .overlay(
            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.trailing, 16),
            alignment: .trailing
        )
        .onTapGesture {
            showDetail = true
        }
        .sheet(isPresented: $showDetail) {
            NavigationView {
                ScrollView {
                    IdeaDetailCard(
                        ideaText: ideaText,
                        ratingString: ratingString,
                        why: why,
                        evidence: evidence,
                        commentCounts: commentCounts
                    )
                    .padding()
                }
                .navigationTitle("Idea Details")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Close") {
                            showDetail = false
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Rating logic
    
    /// Convert database rating string to enum
    private var convertedRating: IdeaRating {
        switch ratingString.lowercased() {
        case "good": return .good
        case "risky": return .risky
        default: return .neutral
        }
    }
    
    @ViewBuilder
    private func ratingPill(for rating: IdeaRating) -> some View {
        Text(rating.label)
            .font(.system(size: 11, weight: .medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(rating.pillBackground)
            .foregroundColor(rating.pillTextColor)
            .cornerRadius(4)
    }
}

// MARK: - Preview

struct IdeaSummaryCard_Previews: PreviewProvider {
    static var previews: some View {
        IdeaSummaryCard(
            ideaText: "Short videos within categorised playlist on ADA essential informations",
            ratingString: "good",
            why: "This idea has strong support from multiple users.",
            evidence: IdeaInsightEvidence(
                prosIds: [
                    EvidenceItem(id: 1, text: "Fun and engaging"),
                    EvidenceItem(id: 2, text: "Easy to understand")
                ],
                risksIds: [
                    EvidenceItem(id: 3, text: "Time consuming")
                ],
                whiteFactsIds: [
                    EvidenceItem(id: 4, text: "Related to learning styles")
                ]
            ),
            commentCounts: CommentCounts(yellow: 5, black: 1, darkGreen: 2)
        )
        .padding(16)
        .previewLayout(.sizeThatFits)
    }
}

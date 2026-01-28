//
//  IdeaInsightCard.swift
//  ADA_C6-sunrice
//
//  Created by Antigravity on 26/11/25.
//

import SwiftUI

struct IdeaInsightCard: View {
    let ideaText: String
    let rating: String  // "good", "neutral", "risky"
    let why: String
    let commentCounts: CommentCounts?
    
    private var ratingColor: Color {
        switch rating.lowercased() {
        case "good": return .green
        case "risky": return .red
        default: return .gray
        }
    }
    
    private var ratingLabel: String {
        switch rating.lowercased() {
        case "good": return "🟢 Good"
        case "risky": return "🔴 Risky"
        default: return "⚪ Neutral"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Idea text
            Text(ideaText)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            // Rating badge
            HStack(spacing: 8) {
                Text(ratingLabel)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(ratingColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(ratingColor.opacity(0.1))
                    .cornerRadius(12)
                
                Spacer()
                
                // Comment counts if available
                if let counts = commentCounts {
                    HStack(spacing: 8) {
                        if counts.yellow > 0 {
                            CommentBadge(count: counts.yellow, color: .yellow)
                        }
                        if counts.black > 0 {
                            CommentBadge(count: counts.black, color: .black)
                        }
                        if counts.darkGreen > 0 {
                            CommentBadge(count: counts.darkGreen, color: AppColor.green50)
                        }
                    }
                }
            }
            
            // Why text
            Text(why)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.grayscale10)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .inset(by: 0.5)
                .stroke(ratingColor.opacity(0.3), lineWidth: 1.5)
        )
    }
}

// Helper badge view for comment counts
private struct CommentBadge: View {
    let count: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text("\(count)")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(Color.grayscale20)
        .cornerRadius(8)
    }
}

#Preview {
    VStack {
        IdeaInsightCard(
            ideaText: "Short videos within categorised playlist on ADA essential informations",
            rating: "neutral",
            why: "This idea has balanced feedback with no clear advantage or disadvantage identified.",
            commentCounts: CommentCounts(yellow: 2, black: 1, darkGreen: 1)
        )
        
        IdeaInsightCard(
            ideaText: "Guidebook on who's who and their expertise",
            rating: "risky",
            why: "Multiple risks identified without sufficient benefits to outweigh concerns.",
            commentCounts: CommentCounts(yellow: 1, black: 3, darkGreen: 0)
        )
        
        IdeaInsightCard(
            ideaText: "Material to prepare for CBL process",
            rating: "good",
            why: "Strong benefits identified with minimal risks. Recommended for implementation.",
            commentCounts: CommentCounts(yellow: 4, black: 1, darkGreen: 2)
        )
    }
    .padding()
}

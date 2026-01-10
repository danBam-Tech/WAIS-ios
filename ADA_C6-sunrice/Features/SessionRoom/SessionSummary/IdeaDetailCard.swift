//
//  IdeaDetailCard.swift
//  ADA_C6-sunrice
//
//  Created by Saskia on 25/11/25.
//

import SwiftUI

// MARK: - Segments

enum IdeaDetailSegment: String, CaseIterable, Identifiable {
    case benefits
    case risks
    case facts
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .benefits: return "Benefits"
        case .risks:    return "Risks"
        case .facts:    return "Facts & Info"
        }
    }
}

// MARK: - Detail Card

struct IdeaDetailCard: View {
    let ideaText: String
    let ratingString: String
    let why: String
    let evidence: IdeaInsightEvidence
    let commentCounts: CommentCounts?
    
    @State private var selectedSegment: IdeaDetailSegment = .benefits
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Idea text
            VStack(alignment: .leading, spacing: 8) {
                Text("Idea:")
                    .font(.labelMD)
                Text(ideaText)
                    .font(.bodySM)
                    .foregroundColor(Color(.label))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Rating row
            HStack(spacing: 6) {
                Text("Rating:")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(.secondaryLabel))
                
                ratingPill(for: convertedRating)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Why: ")
                    .font(.labelMD)
                Text(why)
                    .font(.bodySM)
            }
            
            // Segments (fixed)
            segmentTabs
            
            // Segment content
            segmentContent
        }
        .padding(16)
        .frame(width: 360, alignment: .topLeading)
        .background(AppColor.grayscale10)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
    
    // MARK: - Segments bar (underline style)
    
    private var segmentTabs: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let segmentWidth = totalWidth / 3
            
            VStack(alignment: .leading, spacing: 4) {
                
                // Top row: labels
                HStack(spacing: 0) {
                    ForEach(IdeaDetailSegment.allCases) { segment in
                        let isSelected = (segment == selectedSegment)
                        
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedSegment = segment
                            }
                        } label: {
                            Text(segment.title)
                                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                                .foregroundColor(
                                    isSelected
                                    ? AppColor.Primary.blue
                                    : AppColor.grayscale40
                                )
                                .frame(width: segmentWidth, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // Baseline + underline indicator
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(AppColor.grayscale40)
                        .frame(height: 1)
                    
                    // Blue underline under selected tab
                    Rectangle()
                        .fill(AppColor.Primary.blue)
                        .frame(width: segmentWidth * 0.7, height: 2)
                        .offset(x: underlineOffset(segmentWidth: segmentWidth))
                }
            }
        }
        .frame(height: 32)   // enough height for labels + underline
    }
    
    private func underlineOffset(segmentWidth: CGFloat) -> CGFloat {
        let index: CGFloat
        switch selectedSegment {
        case .benefits: index = 0
        case .risks:    index = 1
        case .facts:    index = 2
        }
        // center the underline roughly under the text
        return index * segmentWidth + segmentWidth * 0
    }
    
    // MARK: - Segment Content
    
    @ViewBuilder
    private var segmentContent: some View {
        switch selectedSegment {
        case .benefits:
            if let pros = evidence.prosIds, !pros.isEmpty {
                VStack(spacing: 8) {
                    ForEach(pros, id: \.id) { item in
                        IdeaBubbleView(
                            text: item.text,
                            type: .yellow,
                            ideaId: Int(item.id)
                        )
                    }
                }
            } else {
                Text("No benefits added yet.")
                    .font(.system(size: 12))
                    .foregroundColor(Color(.secondaryLabel))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        case .risks:
            if let risks = evidence.risksIds, !risks.isEmpty {
                VStack(spacing: 8) {
                    ForEach(risks, id: \.id) { item in
                        IdeaBubbleView(
                            text: item.text,
                            type: .black,
                            ideaId: Int(item.id)
                        )
                    }
                }
            } else {
                Text("No risks added yet.")
                    .font(.system(size: 12))
                    .foregroundColor(Color(.secondaryLabel))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        case .facts:
            if let facts = evidence.whiteFactsIds, !facts.isEmpty {
                VStack(spacing: 8) {
                    ForEach(facts, id: \.id) { item in
                        IdeaBubbleView(
                            text: item.text,
                            type: .white,
                            ideaId: Int(item.id)
                        )
                    }
                }
            } else {
                Text("No facts & info added yet.")
                    .font(.system(size: 12))
                    .foregroundColor(Color(.secondaryLabel))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    // MARK: - Rating Helpers
    
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

//struct IdeaDetailCard_Previews: PreviewProvider {
//    static var previews: some View {
//        IdeaDetailCard(
//            ideaText: "Short videos within categorised playlist on ADA essential informations"
//        )
//        .padding()
//        .previewLayout(.sizeThatFits)
//    }
//}

//
//  InsightCategoryListView.swift
//  WAIS
//
//  Created by Saskia on 25/11/25.
//

import SwiftUI

// MARK: - Model

struct InsightCategory: Identifiable {
    let id = UUID()
    let title: String
    let body: String
    let sources: [String]   // raw source quotes that will be shown as idea bubbles
}

// MARK: - Row

struct InsightCategoryRow: View {
    let category: InsightCategory

    var body: some View {
        HStack(spacing: 16) {

            // Text Block
            VStack(alignment: .leading, spacing: 16) {
                Text(category.title)
                    .font(.titleSSM)
                    .foregroundColor(Color(red: 0.14, green: 0.15, blue: 0.16))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(category.body)
                    .font(.bodySM)
                    .lineSpacing(6.4)                    .foregroundColor(Color(red: 0.14, green: 0.15, blue: 0.16))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Chevron – vertically centered
            Image(systemName: "chevron.right")
                .font(.labelMD)
                .foregroundColor(Color(red: 0.14, green: 0.15, blue: 0.16))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

// MARK: - Card Container with Sheet Navigation

struct InsightCategoryListCard: View {
    let items: [InsightCategory]
    let type: MessageCardType

    @State private var selectedCategory: InsightCategory?

    var body: some View {
        VStack(spacing: 0) {
            ForEach(items.indices, id: \.self) { index in

                Button {
                    selectedCategory = items[index]
                } label: {
                    InsightCategoryRow(category: items[index])
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if index < items.count - 1 {
                    Divider()
                        .padding(.horizontal, 16) // align with text
                }
            }
        }
        .background(.grayscale10)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .inset(by: 0.5)
                .stroke(Color(red: 0.89, green: 0.9, blue: 0.91), lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .sheet(item: $selectedCategory) { category in
            InsightCategoryDetailView(category: category, type: type)
        }
    }
}

// MARK: - Preview

struct InsightCategoryListView_Previews: PreviewProvider {
    static var previews: some View {
        InsightCategoryListCard(
            items: [
                InsightCategory(
                    title: "Learner Needs & Experience Uncertainty",
                    body: "There is a strong sense of confusion and uncertainty about understanding the learner's core needs and what truly drives a better learning experience and future employability. This involves grappling with diverse learner interests and determining the most impactful areas to address.",
                    sources: [
                        "Learner too diverse. Hard to accomodate them",
                        "Confused on what's the most important for the learner",
                        "Does better experience = better hirability? have more fun during the experience",
                        "I don't know what's the main problem that a learner is having"
                    ]
                ),
                InsightCategory(
                    title: "Teamwork & Collaboration",
                    body: "A prevailing feeling of confusion stems from insufficient information and a lack of clarity on project direction or specific challenges.",
                    sources: [
                        "We rarely have clear direction during teamwork.",
                        "Sometimes I don't know what my role is in the group."
                    ]
                )],
            type: .red
        )
        .previewLayout(.sizeThatFits)
    }
}

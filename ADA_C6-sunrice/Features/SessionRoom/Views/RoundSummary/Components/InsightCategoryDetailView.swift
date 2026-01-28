//
//  InsightCategoryDetailView.swift
//  ADA_C6-sunrice
//
//  Created by Komang Wikananda on 26/11/25.
//

import SwiftUI

// MARK: - Detail View (matches the PNG)

struct InsightCategoryDetailView: View {
    let category: InsightCategory
    let type: MessageCardType

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // Title
                    Text(category.title)
                        .font(.titleSSM)
                        .foregroundColor(Color(red: 0.14, green: 0.15, blue: 0.16))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Body
                    Text(category.body)
                        .font(.bodySM)
                        .lineSpacing(6.4)

                        .foregroundColor(Color(red: 0.14, green: 0.15, blue: 0.16))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Source Label
                    Text("Source:")
                        .font(.titleSSM)
                        .foregroundColor(Color(red: 0.14, green: 0.15, blue: 0.16))
                        .padding(.top, 8)

                    // Source Bubbles
                    VStack(spacing: 12) {
                        ForEach(Array(category.sources.enumerated()), id: \.offset) { index, source in
                            IdeaBubbleView(
                                text: source,
                                type: type,        // red strip, like in your PNG
                                ideaId: index
                            )
                        }
                    }
                }
                .frame(maxHeight: .infinity)
                .padding(24)
                .background(.grayscale10)
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .fill(.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .strokeBorder(
                            AppColor.grayscale20,
                            lineWidth: 1)
                )
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .padding(.bottom, 32)
            }
            .background(Color(.grayscale10).ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    let category = InsightCategory(
        title: "Teamwork & Collaboration",
        body: "A prevailing feeling of confusion stems from insufficient information and a lack of clarity on project direction or specific challenges.",
        sources: [
            "We rarely have clear direction during teamwork.",
            "Sometimes I don't know what my role is in the group."
        ]
    )
    InsightCategoryDetailView(category: category, type: .white)
}

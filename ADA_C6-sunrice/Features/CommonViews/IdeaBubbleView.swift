//
//  IdeaBubbleView.swift
//  ADA_C6-sunrice
//
//  Created by Selena Aura on 10/11/25.
//

import SwiftUI

enum MessageCardType: Int {
    case white=1, green=2, darkGreen=3, yellow=4, black=5, red=6
    
    var color: Color {
        switch self {
        case .white:
            return AppColor.whiteishBlue50
        case .green:
            return AppColor.green50
        case .yellow:
            return AppColor.yellow50
        case .black:
            return AppColor.grayscale50
        case .red:
            return AppColor.red50
        case .darkGreen:
            return AppColor.green60
        }
    }
}

struct IdeaBubbleView: View {
    let text: String
    let type: MessageCardType
    let ideaId: Int
    var yellowMessages: Int = -1
    var blackMessages: Int = -1
    var darkGreenMessages: Int = -1
    var showPlusButton: Bool = false
    var onTapPlus: (Int) -> Void = { _ in }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Message
            HStack(spacing: 0) {
                Rectangle()
                    .frame(width: 16)
                    .foregroundStyle(type.color)
                HStack(spacing: 8) {
                    Text(text)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if showPlusButton {
                        Button(action: {onTapPlus(1)}) {
                            Image(systemName: "plus.circle.dashed")
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
            }
            .fixedSize(horizontal: false, vertical: true)
            .background(.grayscale10)
            .clipShape(
                RoundedRectangle(cornerRadius: 20)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.grayscale20)
            }
            
            // Badge
            if isBadgeShown() {
                BadgeView(
                    yellowMessageCount: yellowMessages,
                    blackMessageCount: blackMessages,
                    darkGreenMessageCount: darkGreenMessages
                )
                    .offset(x: -20, y: 14)
            }
        }
        .padding(.bottom, isBadgeShown() ? 16 : 0)
    }
    
    private func isBadgeShown() -> Bool {
        return yellowMessages > 0 || blackMessages > 0 || darkGreenMessages > 0
    }
}

struct BadgeView: View {
    var yellowMessageCount: Int = 0
    var blackMessageCount: Int = 0
    var darkGreenMessageCount: Int = 0
    
    var body: some View {
        HStack(spacing: 8) {
            if darkGreenMessageCount > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.right.circle.fill")
                    Text("\(darkGreenMessageCount)")
                }
                .font(.callout)
                .foregroundStyle(AppColor.green70)
                .bold()
            }
            if yellowMessageCount > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.right.circle.fill")
                    Text("\(yellowMessageCount)")
                }
                .font(.callout)
                .foregroundStyle(.yellow)
                .bold()
            }
            if blackMessageCount > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.right.circle.fill")
                    Text("\(blackMessageCount)")
                }
                .font(.callout)
                .foregroundStyle(.black)
                .bold()
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.white)
        .clipShape(
            Capsule()
        )
        .overlay {
            Capsule()
                .stroke(.grayscale20)
        }
    }
}

#Preview {
    VStack {
        IdeaBubbleView(
            text: "Hello! This is a sample idea.",
            type: .white,
            ideaId: 1
        )
        IdeaBubbleView(
            text: "Hello! This is a sample idea.",
            type: .green,
            ideaId: 1
        )
        IdeaBubbleView(
            text: "Hello! This is a sample idea.",
            type: .green,
            ideaId: 1,
            yellowMessages: 2
        )
        IdeaBubbleView(
            text: "Hello! This is a sample idea.",
            type: .green,
            ideaId: 1,
            yellowMessages: 2,
            blackMessages: 2
        )
        IdeaBubbleView(
            text: "Hello! This is a sample idea.",
            type: .yellow,
            ideaId: 1
        )
        IdeaBubbleView(
            text: "Hello! This is a sample idea.",
            type: .black,
            ideaId: 1
        )
        IdeaBubbleView(
            text: "Hello! This is a sample idea.",
            type: .red,
            ideaId: 1
        )
        IdeaBubbleView(
            text: "Hello! This is a sample idea.",
            type: .darkGreen,
            ideaId: 1
        )
    }
    .padding()
}

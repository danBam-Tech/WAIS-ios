//
//  SelectedPreset.swift
//  ADA_C6-sunrice
//
//  Created by Komang Wikananda on 17/11/25.
//

import SwiftUI

struct SelectedPreset: View {
    var title: String? = "Preset"
    var description: String? = "Description"
    var showStats: Bool = true
    var duration: String? = "30 min"
    var numOfRounds: Int = 6
    var sequence: [String] = ["w", "g", "g", "y", "b", "r"]
    
    private var sequenceColors: [sequenceColor] {
        sequence.compactMap { sequenceColor(rawValue: $0.lowercased()) }
    }
    private func color(for code: sequenceColor) -> Color {
        switch code {
        case .red:    return AppColor.Primary.red
        case .yellow: return AppColor.Primary.yellow
        case .green:  return AppColor.Primary.green
        case .black:  return AppColor.grayscale70
        case .white:  return AppColor.grayscale20
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title ?? "Preset")
                .font(.labelMD)
                .foregroundColor(AppColor.Primary.gray)
            
            // Stats info
            if showStats {
                HStack {
                    Image(systemName: "clock")
                    Text("~\(duration ?? "30 min")")
                    Text("•")
                    Text("\(sequenceColors.isEmpty ? numOfRounds : sequenceColors.count) rounds")
                }
                .foregroundColor(AppColor.Primary.gray)
                .font(.bodySM)
            }
            
            // Description
            Text("\(description ?? "Description")")
                .font(.bodySM)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Sequences
            HStack {
                ForEach(Array(sequenceColors.enumerated()), id: \.offset) { idx, code in
                    Circle()
                        .fill(color(for: code))
                        .frame(width: 18, height: 18)
                    
                    if idx < sequenceColors.count - 1 {
                        Image(systemName: "arrow.right")
                            .font(Font.bodySM.weight(.light))
                    }
                }
            }
            
            // Another description
            Text("You’ll move through each round together — one focus at a time.")
                .font(.bodySM)
                .foregroundColor(AppColor.Primary.gray)
                .italic(true)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(AppColor.whiteishBlue10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(AppColor.Primary.blue, lineWidth: 2)
        )
        .contentShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    SelectedPreset()
}

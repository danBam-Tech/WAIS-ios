//
//  DurationSelector.swift
//  ADA_C6-sunrice
//
//  Created by Komang Wikananda on 17/11/25.
//

import SwiftUI

struct DurationSelector: View {
    @Binding var durationPerRound: Int64
    let totalRounds: Int64 = 6
    
    var totalDuration: String {
        formatDuration(durationPerRound * totalRounds)
    }
    
    private func formatDuration(_ seconds: Int64) -> String {
        let minutes = Double(seconds) / 60.0
        if minutes.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(minutes)) min"
        } else {
            return String(format: "%.1f min", minutes)
        }
    }
    
    var body: some View {
        HStack(spacing: 24) {
            // Time Stepper
            VStack(alignment: .leading, spacing: 12) {
                Text("Duration per Round")
                    .font(.labelMD)
                    .foregroundColor(AppColor.Primary.gray)
                
                HStack {
                    Button(action: {durationPerRound = max(30, durationPerRound - 30)}) {
                        Image(systemName: "minus")
                            .font(.symbolM)
                            .foregroundColor(AppColor.Primary.gray)
                            .frame(maxWidth: 24, maxHeight: 20)
                    }
                    Spacer()
                    Text("\(durationPerRound) sec")
                        .font(.symbolM)
                        .foregroundColor(AppColor.Primary.gray)
                        .frame(maxWidth: 64, maxHeight: 20)
                    Spacer()
                    Button(action: {durationPerRound = min(1800, durationPerRound + 30)}) {
                        Image(systemName: "plus")
                            .font(.symbolM)
                            .foregroundColor(AppColor.Primary.gray)
                            .frame(maxWidth: 24, maxHeight: 20)
                    }
                }
                .padding()
                .frame(maxWidth: 156, maxHeight: 36)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(
                            AppColor.grayscale20,
                            lineWidth: 2)
                )
                .contentShape(RoundedRectangle(cornerRadius: 10))
                
            }
            // Total duration
            VStack(alignment: .leading, spacing: 12) {
                Text("Total Duration")
                    .font(.labelMD)
                    .foregroundColor(AppColor.Primary.gray)
                
                Text("~\(totalDuration)")
                    .frame(maxWidth: 114, maxHeight: 36)
                    .font(.symbolM)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(AppColor.whiteishBlue10)
                    )
                    .contentShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}

#Preview {
    @Previewable @State var durationPerRound: Int64 = 300
    DurationSelector(durationPerRound: $durationPerRound)
}

//
//  RoomPrompt.swift
//  ADA_C6-sunrice
//
//  Created by Hanna Nadia Savira on 23/11/25.
//

import SwiftUI

struct RoomPrompt: View {
    let title: String

    var body: some View {
        HStack {
            Image(systemName: "info.bubble")
            Text(title)
                .font(.caption)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(.whiteishBlue10)
        .clipShape(
            RoundedRectangle(cornerRadius: 12)
        )
        .padding(.horizontal)
    }
}

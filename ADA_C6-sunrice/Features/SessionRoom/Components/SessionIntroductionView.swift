//
//  IntroductionView.swift
//  ADA_C6-sunrice
//
//  Created by Hanna Nadia Savira on 23/11/25.
//

import SwiftUI

struct SessionIntroductionView: View {
    let introduction: SessionIntroduction
    let currentPlayers: Int = 0
    let totalPlayers: Int = 0

    var body: some View {
        VStack(spacing: 48) {
            Text(introduction.title)
                .font(.titleMD)
                .multilineTextAlignment(.center)
            Image(introduction.mascot)
                .frame(width: 134, height: 134)
            if currentPlayers < totalPlayers {
                VStack(spacing: 8) {
                    Text("Waiting For The\nTeam To Be Ready")
                        .multilineTextAlignment(.center)
                    Text("\(currentPlayers)/\(totalPlayers)")
                }
                .font(.titleMD)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .onTapToDismissKeyboard()
        .background(Background())
    }
}

#Preview {
    SessionIntroductionView(introduction: .init(title: "Hello", mascot: "sun"))
}

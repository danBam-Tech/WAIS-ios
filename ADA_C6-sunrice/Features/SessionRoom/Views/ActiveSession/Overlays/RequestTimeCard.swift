//
//  InstructionCard.swift
//  ADA_C6-sunrice
//
//  Created by Hanna Nadia Savira on 23/11/25.
//  Refactored by Antigravity on 23/01/26.
//

import SwiftUI
import Lottie

struct RequestTimeCard: View {
    let requester: String
    let onTap: () -> Void

    var body: some View {
        ZStack {
            Color.black
                .opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 43) {
                VStack(spacing: 52) {
                    // TOP TEXT BLOCK
                    VStack(spacing: 8) {
                        // New heading from SessionInstruction
                        Text("Time Request")
                            .font(.titleLG)
                            .multilineTextAlignment(.center)

                        Text("\(requester) wants to request more time.")
                            .font(.system(size: 16, weight: .regular).italic())
                            .multilineTextAlignment(.center)
                    }

                    // MASCOT → now Lottie animation
                    LottieView(name: "times_up_clock_animation", loopMode: .loop)
                        .frame(width: 240, height: 240)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 24)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
            
            VStack {
                Spacer()
                AppButton(title: "ADD MORE TIME", action: onTap)
                    .padding(.horizontal, 16)
            }
            .padding(.horizontal)
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .onTapToDismissKeyboard()
    }
}

// MARK: - Preview

struct RequestTimeCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RequestTimeCard(
                requester: "Tude",
                onTap: {}
            )
            .previewDisplayName("White / CLARITY")
        }
    }
}

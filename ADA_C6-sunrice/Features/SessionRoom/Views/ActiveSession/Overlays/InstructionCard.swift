//
//  InstructionCard.swift
//  ADA_C6-sunrice
//
//  Created by Hanna Nadia Savira on 23/11/25.
//  Refactored by Antigravity on 23/01/26.
//

import SwiftUI
import Lottie

struct InstructionCard: View {
    let instruction: SessionInstruction
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
                        Text("Instruction")
                            .font(.callout)
                            .opacity(0.7)

                        // New heading from SessionInstruction
                        Text(instruction.heading)
                            .font(.titleLG)
                            .multilineTextAlignment(.center)

                        Text(instruction.subtitle)
                            .font(.system(size: 16, weight: .regular).italic())
                            .multilineTextAlignment(.center)
                    }

                    // MASCOT → now Lottie animation
                    LottieView(name: instruction.mascot, loopMode: .loop)
                        .frame(width: 240, height: 240)

                    Text(instruction.body)
                        .font(.system(size: 14, weight: .regular))
                        .multilineTextAlignment(.center)
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
                AppButton(title: "LET'S GO", action: onTap)
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

struct InstructionCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            InstructionCard(
                instruction: SessionRoom.fact.shared.instruction,
                onTap: {}
            )
            .previewDisplayName("White / CLARITY")
        }
    }
}

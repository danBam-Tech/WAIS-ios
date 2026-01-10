//
//  PreparingSessionLS.swift
//  ADA_C6-sunrice
//
//  Created by Komang Wikananda on 23/11/25.
//

import SwiftUI
import Lottie

struct PreparingLoadingScreen: View {
    var body: some View {
        VStack(spacing: 8) {
            LottieView(name: "splash_animation", loopMode: .loop)
                .frame(width: 350, height: 350)
            VStack (spacing: 24) {
                ProgressView("Preparing your space for flow...")
                    .font(.titleSM)
                    .foregroundStyle(AppColor.Primary.gray)
                VStack {
                    Text("We’re aligning the rhythm and setting focus for the first color round.")
                        .font(.bodySM)
                        .multilineTextAlignment(.center)
                    Text("Take a breath — thinking begins in a moment.")
                        .font(.bodySM)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: 360)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Background())
    }
}

#Preview {
    PreparingLoadingScreen()
}

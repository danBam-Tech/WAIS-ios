import SwiftUI
import Lottie

struct OnboardingPage1View: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            VStack {
                VStack {
                    Image(.blueCharacterAlone)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                }
                .frame(maxHeight: 350)
                VStack(spacing: 20) {
                    Text("Welcome to WAIS")
                        .font(.titleMD)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AppColor.Primary.gray)
                    Text("Here, structure meets flow.\nEach session helps every voice be heard equally — clear, focused, and free from bias.")
                        .multilineTextAlignment(.center)
                        .font(.bodySM)
                        .foregroundStyle(AppColor.Primary.gray)
                }
            }
        }
    }
}

struct OnboardingPage2View: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            VStack {
                VStack {
                    Image(.colorRounds)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                }
                .frame(maxHeight: 350)
                VStack(spacing: 20) {
                    Text("Think in color, \none focus at a time")
                        .font(.titleMD)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AppColor.Primary.gray)
                    Text("WAIS leads you through a color flow — a sequence of guided color rounds that represents a different way of thinking. \nTogether, they turn group thinking into rhythm and clarity.")
                        .multilineTextAlignment(.center)
                        .font(.bodySM)
                        .foregroundStyle(AppColor.Primary.gray)

                }
            }
        }
    }
}

struct OnboardingPage3View: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            VStack {
                VStack {
                    // LOTTIE ANIMATION REPLACING IMAGE
                    LottieView(name: "splash_animation", loopMode: .loop)
                        .frame(width: 300, height: 300)
                }
                .frame(maxHeight: 350)

                VStack(spacing: 20) {
                    Text("Ready to begin \nyour first flow?")
                        .font(.titleMD)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AppColor.Primary.gray)

                    Text("You’re about to enter a guided rhythm of thinking — calm, structured, and collective.\nStep into the first color flow and let ideas unfold naturally.")
                        .multilineTextAlignment(.center)
                        .font(.bodySM)
                        .foregroundStyle(AppColor.Primary.gray)
                }
            }
        }
    }
}

#Preview {
    OnboardingPage2View()
}

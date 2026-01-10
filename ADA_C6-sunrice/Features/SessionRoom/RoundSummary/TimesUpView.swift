//
//  TimesUpView.swift
//  ADA_C6-sunrice
//
//  Created by Hanna Nadia Savira on 23/11/25.
//

import SwiftUI
import Lottie

// MARK: - Lottie SwiftUI Wrapper

struct LottieView: UIViewRepresentable {
    let name: String
    var loopMode: LottieLoopMode = .loop
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView(frame: .zero)
        
        let animationView = LottieAnimationView(name: name) // JSON file name (without .json)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.play()
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: containerView.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // No dynamic updates needed for now
    }
}

// MARK: - Time's Up Screen

struct TimesUpView: View {
    var body: some View {
        VStack(spacing: 12) {
            LottieView(name: "times_up_clock_animation", loopMode: .loop)
                .frame(width: 300, height: 300)
            
            VStack(spacing: 4) {
                Text("TIME'S UP!")
                    .font(.titleLG)
                    .multilineTextAlignment(.center)
                
                Text("Nice work! Your input here helps shape the bigger picture.")
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(.blue50)
        .padding(.horizontal, 24)
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .onTapToDismissKeyboard()
        .background(Background())
    }
}

// MARK: - Preview

struct TimesUpView_Previews: PreviewProvider {
    static var previews: some View {
        TimesUpView()
            .previewLayout(.sizeThatFits)
    }
}

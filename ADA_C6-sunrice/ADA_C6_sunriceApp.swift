//
//  ADA_C6_sunriceApp.swift
//  ADA_C6-sunrice
//
//  Created by Komang Wikananda on 27/10/25.
//

import SwiftUI

@main
struct ADA_C6_sunriceApp: App {
    @State private var hasCompletedOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                HomeView()
            } else {
                OnboardingView {
                    hasCompletedOnboarding = true
                }
            }
        }
    }
}

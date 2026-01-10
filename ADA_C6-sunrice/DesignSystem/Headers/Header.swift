//
//  Header.swift
//  ADA_C6-sunrice
//
//  Created by Komang Wikananda on 15/11/25.
//

import SwiftUI

enum HeaderTrailing {
    case none
    case timer(date: Date)
    case skip(action: () -> Void)
}

struct HeaderConfig {
    var title: String?
    var showsBackButton: Bool = true
    var trailing: HeaderTrailing = .none
}

struct Header: View {
    @Environment(\.dismiss) var dismiss
    let config: HeaderConfig
    var onBack: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            // CENTER: title (always centered)
            if let title = config.title {
                Text(title)
                    .bold()
                    .font(.titleSM)
                    .foregroundStyle(AppColor.Primary.gray)
                    .frame(maxWidth: 250)
                    .multilineTextAlignment(.center)
            }
            
            // LEFT & RIGHT: leading/trailing buttons
            HStack {
                // LEFT: back button
                if config.showsBackButton {
                    BackButton(action: {
                        if let onBack { onBack() } else { dismiss() }
                    })
                } else {
                    Color.clear
                        .frame(width: 44, height: 35)
                }
                
                Spacer()
                
                // RIGHT: trailing view (skip or timer)
                trailingView
            }
        }
    }
    
    @ViewBuilder
    private var trailingView: some View {
        switch config.trailing {
        case .none:
            Color.clear
                .frame(maxWidth: 100, maxHeight: 35)
            
        case .skip(let action):
            SkipButton(action: action)
            
        case .timer(let date):
            TimerTag(date: date)
        }
    }
}

#Preview {
    Header(
        config: .init(
            title: "Header",
            showsBackButton: true,
//            trailing: .skip(action: {})
            trailing: .timer(date: Date.now)
//            trailing: .none
    ))
}

//
//  WhiteLS.swift
//  ADA_C6-sunrice
//
//  Created by Komang Wikananda on 23/11/25.
//

import SwiftUI

enum ImageName: String, CaseIterable {
    case lsWhite = "ls_white"
    case blackCharacter = "Black Character"
    case yellowCharacter = "Yellow Character"
    case redCharacter = "Red Character"
    case whiteCharacter = "White Character"
    case greenCharacter = "Green Character"
    
    var uiImage: UIImage {
        UIImage(named: rawValue) ?? UIImage()
    }
}

enum RoundType {
    case white, red, black, yellow, green, darker_green
    
    var title: String {
        switch self {
        case .white: return "Let’s Put Every Facts & Information You Know"
        case .red: return "Let’s Put Your Feelings About The Ideas"
        case .darker_green: return "Let’s Build on These Ideas"
        case .black: return "Let’s Analyze The Risks The Ideas"
        case .yellow: return "Let’s Seek The Benefits The Ideas"
        case .green: return "Let’s Generates Some Ideas!"
        }
    }
    
    var imageName: ImageName {
        switch self {
        case .white: return .lsWhite
        case .red: return .redCharacter
        case .black: return .blackCharacter
        case .yellow: return .yellowCharacter
        case .green: return .greenCharacter
        case .darker_green: return .greenCharacter
        }
    }
}

struct RoundStartupScreen: View {
    let type: RoundType
    
    var body: some View {
        ZStack {
            VStack(spacing: 48) {
                Text(type.title)
                    .font(.titleSM)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 260)
                Image(type.imageName.rawValue)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 200)
            }
        }
    }
}

#Preview {
    RoundStartupScreen(type: .white)
}

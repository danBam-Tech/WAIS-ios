//
//  ButtonSeeAllCards.swift
//  ADA_C6-sunrice
//
//  Created by Saskia on 25/11/25.
//
import SwiftUI

struct ButtonSeeAllCards: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                Text("See All Cards")
                    .font(.labelMD)
                    .foregroundColor(Color(red: 0.14, green: 0.15, blue: 0.16))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.down")
                    .font(.labelMD)
                    .foregroundColor(Color(red: 0.14, green: 0.15, blue: 0.16))
                    .rotationEffect(.degrees(-90))   //
            }
            .padding(0)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.grayscale10)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(red: 0.89, green: 0.9, blue: 0.91), lineWidth: 1)
        )
    }
}

#Preview {
    ButtonSeeAllCards()
}

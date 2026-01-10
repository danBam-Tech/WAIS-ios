//
//  Background.swift
//  ADA_C6-sunrice
//
//  Created by Komang Wikananda on 14/11/25.
//

import SwiftUI

struct Background: View {
    var body: some View {
        Image(.background)
            .resizable()
            .ignoresSafeArea()
            .scaledToFill()
            .background(.white)
    }
}


#Preview {
    Background()
}

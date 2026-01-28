//
//  DefineSessionView.swift
//  ADA_C6-sunrice
//
//  Created by Komang Wikananda on 17/11/25.
//

import SwiftUI

struct DefineSessionView: View {
    @ObservedObject var vm: CreateSessionViewModel
    
    var body: some View {
        VStack (alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Let’s define this session")
                    .font(.titleSM)
                    .foregroundColor(AppColor.Primary.gray)
                Text("A clear intention helps everyone focus their thoughts. You can keep it simple — one question or theme is enough.")
                    .font(.bodySM)
                    .foregroundColor(AppColor.Primary.gray)
            }
            
            VStack(alignment: .leading) {
                Text("Session Title")
                    .font(.labelMD)
                BoxField(
                    placeholder: "e.g., “How might we make onboarding more delightful?”, “Exploring sustainable ideas.”, etc.",
                    text: $vm.topic
                )
            }
            
            VStack(alignment: .leading) {
                Text("Additional Description (optional)")
                    .font(.labelMD)
                BoxField(
                    placeholder: "e.g, “Let’s find creative ways to boost user engagement without adding extra steps.”, “Looking for story-driven ideas for our next social campaign.”, etc.",
                    text: $vm.description
                )
            }
        }
        .onTapToDismissKeyboard()
    }
}


#Preview {
    DefineSessionView(vm: CreateSessionViewModel(socketManager: WebSocketManager()))
}

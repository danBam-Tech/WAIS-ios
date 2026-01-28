//
//  InputArea.swift
//  ADA_C6-sunrice
//
//  Created by Komang Wikananda on 17/11/25.
//

import SwiftUI

struct InputArea: View {
    @Binding var inputText: String
    var isSending: Bool = false
    var action: () -> Void = {}
    
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            TextField("Type an idea...", text: $inputText, axis: .vertical)
                .font(.bodySM)
                .foregroundColor(AppColor.Primary.gray)
                .textFieldStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(AppColor.blue10)
                .clipShape(Capsule())
                .lineLimit(1...5)
                .frame(maxHeight: 35)
                .focused($isTextFieldFocused)
                .onSubmit {
                    if !isSending {
                        action()
                    }
                }
            
            Button {
                if !isSending && !inputText.isEmpty {
                    action()
                }
            } label: {
                Circle()
                    .fill(AppColor.blue10)
                    .frame(width: 35, height: 35)
                    .overlay(
                        Group {
                            if isSending {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.7)
                            } else {
                                Image(systemName: "paperplane.fill")
                                    .foregroundColor(inputText.isEmpty ? AppColor.grayscale30 : AppColor.Primary.gray)
                            }
                        }
                    )
            }
            .disabled(inputText.isEmpty || isSending)
        }
        .padding(16)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: 20.0,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 20.0
            )
            .strokeBorder(AppColor.grayscale20)
            // workaround to make bottom invisible. not best approach lol
            .mask(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .black, location: 0),
                        .init(color: .black, location: 0.90), // 90% visible
                        .init(color: .clear, location: 1.0)    // bottom hidden
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        )
        .background(AppColor.grayscale10)
    }
}


#Preview {
    @Previewable @State var inputText: String = ""
    InputArea(inputText: $inputText) {
        
    }
}

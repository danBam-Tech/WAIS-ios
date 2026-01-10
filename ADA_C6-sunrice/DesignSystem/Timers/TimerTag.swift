//
//  Untitled.swift
//  ADA_C6-sunrice
//
//  Created by Komang Wikananda on 15/11/25.
//

import SwiftUI

struct TimerTag: View {
    var date: Date
    
    var body: some View {
        Text(date, style: .timer)
            .font(.bodySM)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule().fill(AppColor.blue10)
            )
            .frame(maxWidth: 100, maxHeight: 35, alignment: .trailing)
    }
}

#Preview {
    TimerTag(date: Date.now)
}

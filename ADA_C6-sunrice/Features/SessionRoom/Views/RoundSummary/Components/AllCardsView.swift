//
//  AllCardsView.swift
//  ADA_C6-sunrice
//
//  Created by Antigravity on 26/11/25.
//

import SwiftUI

struct AllCardsView: View {
    @ObservedObject var vm: SessionRoomViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            Header(
                config: .init(
                    title: "All Cards",
                    showsBackButton: true,
                    trailing: .none
                ),
                onBack: { dismiss() }
            )
            .padding(.horizontal)
            
            // Ideas List
            ScrollView {
                LazyVStack(alignment: .trailing, spacing: 8) {
                    // Show green ideas if in comment round, otherwise show current round ideas
                    let ideasToShow = vm.isCommentRound ? vm.serverIdeas.filter { idea in
                        // Filter for green ideas only
                        guard let typeId = idea.type_id else { return false }
                        return typeId == vm.getGreenTypeId()
                    } : vm.serverIdeas
                    
                    ForEach(Array(ideasToShow)) { idea in
                        let counts = vm.commentCounts[idea.id] ?? CommentCounts(yellow: 0, black: 0, darkGreen: 0)
                        
                        VStack(alignment: .trailing, spacing: 8) {
                            // Idea bubble
                            IdeaBubbleView(
                                text: idea.text ?? "",
                                type: vm.isCommentRound ? .green : vm.roomType.shared.type,
                                ideaId: Int(idea.id),
                                yellowMessages: counts.yellow,
                                blackMessages: counts.black,
                                darkGreenMessages: counts.darkGreen,
                                showPlusButton: vm.isCommentRound,
                                onTapPlus: { _ in
                                    vm.openCommentSheet(for: idea)
                                }
                            )
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .background(Background())
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @StateObject var vm: SessionRoomViewModel
        
        init() {
            _vm = StateObject(wrappedValue: SessionRoomViewModel(id: 1, isHost: true))
        }
        
        var body: some View {
            AllCardsView(vm: vm)
        }
    }
    
    return PreviewWrapper()
}

//
//  ConversationDTO.swift
//  ADA_C6-sunrice
//
//  Created by Tude Maha on 28/01/2026.
//

import Foundation

struct ConversationDTO: Hashable, Identifiable {
    var id: UUID {
        UUID()
    }
    var date: Date {
        Date()
    }
    var name: String
    var message: String
    var ideaID = ""
    var role: Role
}

enum Role {
    case send
    case receive
    case system
}

//
//  SocketDTO.swift
//  ADA_C6-sunrice
//
//  Created by Tude Maha on 28/01/2026.
//

import Foundation

struct SocketRequest: Codable, Hashable {
    var action: Action
    var ideaId = ""
    var message: String
}

struct SocketResponse: Codable, Hashable {
    var from: String
    var action: Action
    var message: String
}

enum Action: String, Codable {
    case join
    case message
    case comment
    case leave
    case start
    case finish
    case time_request
    case time_addition
    case change_host
    case next_stage
    case session_summary
    case sequence_summary
}

//
//  SessionPreset.swift
//  ADA_C6-sunrice
//
//  Created by Komang Wikananda on 19/11/25.
//
import Foundation

enum ModeStatus: String, Codable {
    case live
    case beta
    case coming_soon

    var isSelectable: Bool {
        return self == .live || self == .beta
    }
}

struct SessionPreset: Identifiable, Equatable {
    let id: Int64
    let title: String
    let description: String
    let duration: String
    let numOfRounds: Int
    let sequence: [String]
    let overview: String
    let bestFor: [String]
    let outcome: String
    let status: ModeStatus
}

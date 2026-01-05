//
//  ModeDTO.swift
//  ADA_C6-sunrice
//
//  Created by Komang Wikananda on 23/11/25.
//

import Foundation

struct ModeDTO: Decodable {
    let id: Int64
    let name: String?
    let created_at: Date?
    let round_count: Int64?
    let title: String?
    let description: String?
    let duration: String?
    let num_of_rounds: Int64?
    let sequence: [String]?
    let overview: String?
    let best_for: [String]?
    let outcome: String?
    let status: ModeStatus?
}



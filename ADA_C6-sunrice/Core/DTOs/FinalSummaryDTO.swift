//
//  FinalSummaryDTO.swift
//  ADA_C6-sunrice
//
//  Created by Antigravity on 27/11/25.
//

import Foundation

struct FinalSummaryDTO: Codable {
    let id: Int64
    let sessionId: Int64
    let summaryText: String
    let createdAt: String?  // PostgreSQL returns ISO 8601 string, not Unix timestamp
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try multiple keys for summary text
        if let text = try? container.decode(String.self, forKey: .summaryText) {
            summaryText = text
        } else if let text = try? container.decode(String.self, forKey: .summary) {
            summaryText = text
        } else if let text = try? container.decode(String.self, forKey: .text) {
            summaryText = text
        } else if let text = try? container.decode(String.self, forKey: .content) {
            summaryText = text
        } else {
            // If all fail, throw the original error for summary_text to be descriptive
            summaryText = try container.decode(String.self, forKey: .summaryText)
        }
        
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        
        // Handle missing ID (e.g. if response is just the AI text)
        if let dbId = try? container.decode(Int64.self, forKey: .id) {
            id = dbId
        } else {
            id = Int64.random(in: 1...Int64.max)
        }
        
        // Handle missing session ID
        if let sId = try? container.decode(Int64.self, forKey: .sessionId) {
            sessionId = sId
        } else {
            sessionId = 0
        }
    }
    
    // Add extra coding keys for fallback
    enum CodingKeys: String, CodingKey {
        case id
        case sessionId = "session_id"
        case summaryText = "summary_text"
        case createdAt = "created_at"
        // Fallback keys
        case summary
        case text
        case content
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(sessionId, forKey: .sessionId)
        try container.encode(summaryText, forKey: .summaryText)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
    }
}

struct GenerateFinalSummaryResponse: Codable {
    let success: Bool
    let summary: FinalSummaryDTO
    
    enum CodingKeys: String, CodingKey {
        case success, summary
    }
}

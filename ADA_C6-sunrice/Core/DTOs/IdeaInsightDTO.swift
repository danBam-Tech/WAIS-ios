//
//  IdeaInsightDTO.swift
//  ADA_C6-sunrice
//
//  Created by Antigravity on 26/11/25.
//

import Foundation

struct EvidenceItem: Codable {
    let id: Int
    let text: String
}

struct IdeaInsightEvidence: Codable {
    let prosIds: [EvidenceItem]?
    let risksIds: [EvidenceItem]?
    let whiteFactsIds: [EvidenceItem]?
    
    enum CodingKeys: String, CodingKey {
        case prosIds = "pros_ids"
        case risksIds = "risks_ids"
        case whiteFactsIds = "white_facts_ids"
    }
}

struct IdeaInsightDTO: Codable, Identifiable {
    let id: Int64
    let ideaId: Int64
    let sessionId: Int64
    let rating: String  // "good", "neutral", "risky"
    let why: String
    let evidence: IdeaInsightEvidence
    let mitigations: String?  // Array of mitigation strings
    let worstPossibleIdea: String?  // Changed from array to string to match DB schema
    let flipSideIdea: String?  // Changed from array to string to match DB schema
    let notes: String?  // Array of note strings
    
    enum CodingKeys: String, CodingKey {
        case id, rating, why, evidence, mitigations, notes
        case ideaId = "idea_id"
        case sessionId = "session_id"
        case worstPossibleIdea = "worst_possible_idea"
        case flipSideIdea = "flip_side_idea"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        rating = try container.decode(String.self, forKey: .rating)
        why = try container.decode(String.self, forKey: .why)
        evidence = try container.decode(IdeaInsightEvidence.self, forKey: .evidence)
        mitigations = try container.decodeIfPresent(String.self, forKey: .mitigations)
        worstPossibleIdea = try container.decodeIfPresent(String.self, forKey: .worstPossibleIdea)
        flipSideIdea = try container.decodeIfPresent(String.self, forKey: .flipSideIdea)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        
        // Handle potential missing keys from different response formats
        if let dbIdeaId = try? container.decode(Int64.self, forKey: .ideaId) {
            // Database row format (has idea_id)
            ideaId = dbIdeaId
            id = try container.decode(Int64.self, forKey: .id)
            sessionId = try container.decode(Int64.self, forKey: .sessionId)
        } else {
            // AI Response format (id is likely the ideaId)
            let jsonId = try container.decode(Int64.self, forKey: .id)
            ideaId = jsonId
            // Use ideaId as temporary id if real DB id is missing
            id = jsonId 
            // Default session ID if missing (will be filled by context if needed)
            sessionId = (try? container.decode(Int64.self, forKey: .sessionId)) ?? 0
        }
    }
}

struct AnalyzeIdeaResponse: Codable {
    let success: Bool
    let insight: IdeaInsightDTO
    let summaryId: Int64?
    
    enum CodingKeys: String, CodingKey {
        case success, insight
        case summaryId = "summary_id"
    }
}

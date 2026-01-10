//
//  SummaryDTO.swift
//  ADA_C6-sunrice
//
//  Created by Komang Wikananda on 25/11/25.
//

// Ideas summarization and category
struct IdeaSummary: Decodable {
    struct Item: Decodable {
        let id: Int
        let input: String
    }

    struct Theme: Decodable {
        let name: String
        let summary: String
        let items: [Item]? 
    }

    let themes: [Theme]
    let notes: String?
}

struct SummarizeSessionResponse<Summary: Decodable>: Decodable {
    let success: Bool
    let sessionType: String
    let summary: Summary
    let summaryId: Int?

    private enum CodingKeys: String, CodingKey {
        case success
        case sessionType = "session_type"
        case summary
        case summaryId = "summary_id"
    }
}

struct SessionSummaryRow: Decodable {
    let id: Int
    let sessionId: Int
    let roundType: Int
    let themes: [IdeaSummary.Theme]
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case sessionId = "session_id"
        case roundType = "round_type"
        case themes
        case notes
    }
}

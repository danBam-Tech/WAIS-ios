//
//  IdeaInsightService.swift
//  ADA_C6-sunrice
//
//  Created by Antigravity on 26/11/25.
//

import Foundation
import Supabase

final class IdeaInsightService: IdeaInsightServicing {
    private let client: SupabaseClient
    
    init(client: SupabaseClient) {
        self.client = client
    }
    
    // Call analyze-idea edge function for a single green idea
    func analyzeIdea(sessionId: Int, greenIdeaId: Int) async throws -> AnalyzeIdeaResponse {
        struct AnalyzeIdeaRequest: Encodable {
            let session_id: Int
            let green_idea_id: Int
        }
        
        let requestBody = AnalyzeIdeaRequest(
            session_id: sessionId,
            green_idea_id: greenIdeaId
        )
        
        let response: AnalyzeIdeaResponse = try await client.functions.invoke(
            "analyze-idea",
            options: FunctionInvokeOptions(
                body: requestBody
            )
        )
        
        return response
    }
    
    // Fetch all idea insights for a session from database
    func fetchIdeaInsights(sessionId: Int) async throws -> [IdeaInsightDTO] {
        let response: [IdeaInsightDTO] = try await client
            .from("idea_insights")
            .select()
            .eq("session_id", value: sessionId)
            .order("id", ascending: true)
            .execute()
            .value
        
        return response
    }
}

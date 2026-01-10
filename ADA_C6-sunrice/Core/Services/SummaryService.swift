//
//  SummaryService.swift
//  ADA_C6-sunrice
//
//  Created by Komang Wikananda on 25/11/25.
//

import Supabase
import Foundation

struct SummaryService: SummaryServicing {
    let client: SupabaseClient
    
    // Summarize session
    func summarizeWhiteSession(sessionId: Int) async throws -> SummarizeSessionResponse<IdeaSummary> {
        let body: [String: Int] = [
            "session_id": sessionId,
            "idea_type": 1
        ]

        let response: SummarizeSessionResponse<IdeaSummary> = try await client
            .functions
            .invoke(
                "summarize-session",
                options: FunctionInvokeOptions(
                    body: body
                )
            )

        return response
    }
    
    func summarizeGreenSession(sessionId: Int) async throws -> SummarizeSessionResponse<IdeaSummary> {
        let body: [String: Int] = [
            "session_id": sessionId,
            "idea_type": 2
        ]

        let response: SummarizeSessionResponse<IdeaSummary> = try await client
            .functions
            .invoke(
                "summarize-session",
                options: FunctionInvokeOptions(
                    body: body
                )
            )

        return response
    }
    
    func summarizeRedSession(sessionId: Int) async throws -> SummarizeSessionResponse<IdeaSummary> {
        let body: [String: Int] = [
            "session_id": sessionId,
            "idea_type": 6
        ]

        let response: SummarizeSessionResponse<IdeaSummary> = try await client
            .functions
            .invoke(
                "summarize-session",
                options: FunctionInvokeOptions(
                    body: body
                )
            )

        return response
    }
    
    // Fetch existing summary from database (for guests)
    func fetchExistingSummary(sessionId: Int, roundType: Int) async throws -> IdeaSummary? {
        let response: [SessionSummaryRow] = try await client
            .from("session_summaries")
            .select()
            .eq("session_id", value: sessionId)
            .eq("round_type", value: roundType)
            .limit(1)
            .execute()
            .value
        
        if let row = response.first {
            return IdeaSummary(themes: row.themes, notes: row.notes)
        }
        
        return nil
    }
    
    // Generate final summary using RPC function
    func generateFinalSummary(sessionId: Int) async throws -> GenerateFinalSummaryResponse {
        struct GenerateFinalSummaryRequest: Encodable {
            let session_id: Int
        }
        
        let requestBody = GenerateFinalSummaryRequest(session_id: sessionId)
        
        let response: GenerateFinalSummaryResponse = try await client.functions.invoke(
            "generate-final-summary",
            options: FunctionInvokeOptions(
                body: requestBody
            )
        )
        
        return response
    }
    
    // Fetch existing final summary from database
    func fetchFinalSummary(sessionId: Int) async throws -> FinalSummaryDTO? {
        let response: [FinalSummaryDTO] = try await client
            .from("session_final_summaries")
            .select()
            .eq("session_id", value: sessionId)
            .limit(1)
            .execute()
            .value
        
        return response.first
    }
}

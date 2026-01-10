//
//  SessionService.swift
//  ADA_C6-sunrice
//
//  Created by Komang Wikananda on 05/11/25.
//
import PostgREST
import Foundation
import Supabase

struct SessionService: SessionServicing {
    let client: SupabaseClient
    
    func createSession(
        topic: String,
        description: String,
        duration_per_round: Int64,
        mode_id: Int64
    ) async throws -> SessionDTO {
        let params = CreateSessionParams(
            _duration_per_round: Int64(duration_per_round),
            _topic: topic,
            _description: description,
            _mode_id: mode_id
        )
        
        let response: PostgrestResponse<RPCSessionResponseDTO> = try await client
            .rpc("create_session_with_token", params: params)
            .single()
            .execute()
        
        let rpcSession = response.value
        
        return SessionDTO(
            id: rpcSession.session_id,
            duration_per_round: duration_per_round,
            topic: rpcSession.topic,
            description: rpcSession.description,
            token: rpcSession.token,
            is_token_expired: false,
            started_at: nil,
            ended_at: nil,
            created_at: Date(),
            mode_id: rpcSession.mode_id,
            current_round: rpcSession.current_round,
            current_round_deadline: nil
        )
    }
    
    func fetchSession(id: Int64) async throws -> SessionDTO {
        let response: PostgrestResponse<SessionDTO> = try await client
            .from("sessions")
            .select()
            .eq("id", value: Int(id))
            .single()
            .execute()
        
        return response.value
    }
    
    func fetchSession(token: String) async throws -> SessionDTO {
        let response: PostgrestResponse<SessionDTO> = try await client
            .from("sessions")
            .select()
            .eq("token", value: token)
            .single()
            .execute()
        
        return response.value
    }
    
    func fetchMode(id: Int64) async throws -> ModeDTO {
        let response: PostgrestResponse<ModeDTO> = try await client
            .from("modes")
            .select()
            .eq("id", value: Int(id))
            .single()
            .execute()
        
        return response.value
    }
    
    func fetchModes() async throws -> [ModeDTO] {
        let response: PostgrestResponse<[ModeDTO]> = try await client
            .from("modes")
            .select()
            .execute()
        return response.value
    }
    
    func startSession(id: Int64) async throws -> TypeDTO {
        let payload = StartSessionPayload(is_token_expired: true, started_at: Date())
        try await client
            .from("sessions")
            .update(payload)
            .eq("id", value: Int(id))
            .execute()
        
        // Fetch session to get mode_id
        let sessionResponse: PostgrestResponse<SessionDTO> = try await client
            .from("sessions")
            .select()
            .eq("id", value: Int(id))
            .single()
            .execute()
        let session = sessionResponse.value
        
        guard let modeId = session.mode_id else {
            throw NSError(domain: "SessionService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Session has no mode_id"])
        }
        
        // Fetch sequence
        let sequenceResponse: PostgrestResponse<SequenceDTO> = try await client
            .from("sequences")
            .select()
            .eq("mode_id", value: Int(modeId))
            .single()
            .execute()
        let sequence = sequenceResponse.value
        
        guard let firstRoundTypeId = sequence.first_round else {
            throw NSError(domain: "SessionService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Sequence has no first round"])
        }
        
        // Fetch Type
        let typeResponse: PostgrestResponse<TypeDTO> = try await client
            .from("types")
            .select()
            .eq("id", value: Int(firstRoundTypeId))
            .single()
            .execute()
        
        return typeResponse.value
    }
    
    func fetchSequence(modeId: Int64) async throws -> SequenceDTO {
        let response: PostgrestResponse<SequenceDTO> = try await client
            .from("sequences")
            .select()
            .eq("mode_id", value: Int(modeId))
            .single()
            .execute()
        
        return response.value
    }
    
    func updateCurrentRound(sessionId: Int64, round: Int64) async throws {
        let payload = UpdateCurrentRoundPayload(current_round: round)
        try await client
            .from("sessions")
            .update(payload)
            .eq("id", value: Int(sessionId))
            .execute()
    }
    
    func fetchType(id: Int64) async throws -> TypeDTO {
        let response: PostgrestResponse<TypeDTO> = try await client
            .from("types")
            .select()
            .eq("id", value: Int(id))
            .single()
            .execute()
        
        return response.value
    }
    
    func updateRoundDeadline(sessionId: Int64, deadline: Date) async throws {
        let payload = UpdateDeadlinePayload(current_round_deadline: deadline)
        try await client
            .from("sessions")
            .update(payload)
            .eq("id", value: Int(sessionId))
            .execute()
    }
}

private struct StartSessionPayload: Encodable, Sendable {
    let is_token_expired: Bool
    let started_at: Date
}

private struct NewSessionPayload: Encodable, Sendable {
    let duration_per_round: String
    let topic: String
    let description: String?
    let mode_id: Int64
    let token: String
    let is_token_expired: Bool = false
}

private struct UpdateCurrentRoundPayload: Encodable, Sendable {
    let current_round: Int64
}

private struct UpdateDeadlinePayload: Encodable, Sendable {
    let current_round_deadline: Date
}

//
//  Protocols.swift
//  ADA_C6-sunrice
//
//  Created by Codex on 11/13/25.
//
import Foundation

protocol UserServicing {
    func createUser(name: String) async throws -> UserDTO
}

protocol UserRoleServicing {
    func createUserRole(roleId: Int64) async throws -> UserRoleDTO
    func attach(userId: Int64, toRole roleId: Int64) async throws -> UserRoleDTO
    func createUserRoleSession(userId: Int64, roleId: Int64, sessionId: Int64) async throws -> UserRoleSessionDTO
    func fetchParticipants(sessionId: Int64) async throws -> [ParticipantDTO]
}

protocol UserRoleSessionServicing {
    func createUserRoleSession(userId: Int64, roleId: Int64, sessionId: Int64) async throws -> UserRoleSessionDTO
}

protocol SessionServicing {
    func createSession(topic: String,
        description: String,
        duration_per_round: Int64,
        mode_id: Int64
    ) async throws -> SessionDTO
    func fetchSession(id: Int64) async throws -> SessionDTO
    func fetchSession(token: String) async throws -> SessionDTO
    func fetchMode(id: Int64) async throws -> ModeDTO
    func fetchModes() async throws -> [ModeDTO]
    func startSession(id: Int64) async throws -> TypeDTO
    func fetchSequence(modeId: Int64) async throws -> SequenceDTO
    func updateCurrentRound(sessionId: Int64, round: Int64) async throws
    func fetchType(id: Int64) async throws -> TypeDTO
    func updateRoundDeadline(sessionId: Int64, deadline: Date) async throws
}

protocol IdeaServicing {
    func fetchIdeas(sessionId: Int64, typeId: Int64?) async throws -> [IdeaDTO]
    func createIdeas(_ params: [InsertIdeaParams]) async throws
    func createComment(_ params: InsertCommentParams) async throws
    func fetchCommentsForIdeas(ideaIds: [Int64]) async throws -> [IdeaCommentDTO]
}

protocol SummaryServicing {
    func summarizeWhiteSession(sessionId: Int) async throws -> SummarizeSessionResponse<IdeaSummary>
    func summarizeGreenSession(sessionId: Int) async throws -> SummarizeSessionResponse<IdeaSummary>
    func summarizeRedSession(sessionId: Int) async throws -> SummarizeSessionResponse<IdeaSummary>
    func fetchExistingSummary(sessionId: Int, roundType: Int) async throws -> IdeaSummary?
    func generateFinalSummary(sessionId: Int) async throws -> GenerateFinalSummaryResponse
    func fetchFinalSummary(sessionId: Int) async throws -> FinalSummaryDTO?
}

protocol IdeaInsightServicing {
    func analyzeIdea(sessionId: Int, greenIdeaId: Int) async throws -> AnalyzeIdeaResponse
    func fetchIdeaInsights(sessionId: Int) async throws -> [IdeaInsightDTO]
}

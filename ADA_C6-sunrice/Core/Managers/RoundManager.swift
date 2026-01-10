//
//  RoundManager.swift
//  ADA_C6-sunrice
//
//  Created by Antigravity on 24/11/25.
//

import Foundation

struct RoundInfo {
    let typeId: Int64
    let sessionRoom: SessionRoom
    let deadline: Date
}

struct CommentCounts {
    var yellow: Int
    var black: Int
    var darkGreen: Int
}

@MainActor
final class RoundManager {
    private let sessionService: SessionServicing
    private var sequence: SequenceDTO?
    
    init(sessionService: SessionServicing) {
        self.sessionService = sessionService
    }
    
    func setSequence(_ sequence: SequenceDTO) {
        self.sequence = sequence
    }
    
    // MARK: - Round Type Loading
    
    func loadRoundType(round: Int64, session: SessionDTO) async throws -> RoundInfo {
        guard let sequence = sequence else {
            throw RoundManagerError.sequenceNotSet
        }
        
        // Get type ID for current round
        guard let typeId = getTypeIdForRound(round) else {
            throw RoundManagerError.noTypeForRound(round)
        }
        
        // Fetch type from database
        let type = try await sessionService.fetchType(id: typeId)
        
        // Map type name to SessionRoom enum
        let sessionRoom = mapTypeToSessionRoom(typeName: type.name ?? "")
        
        // Calculate deadline (10 seconds for testing, should use session.duration_per_round in production)
//        let deadline = Date().addingTimeInterval(20)
         let deadline = Date().addingTimeInterval(TimeInterval(session.duration_per_round ?? 60))
        
        return RoundInfo(typeId: typeId, sessionRoom: sessionRoom, deadline: deadline)
    }
    
    // MARK: - Type ID Mapping
    
    func getTypeIdForRound(_ round: Int64) -> Int64? {
        guard let sequence = sequence else { return nil }
        
        switch round {
        case 1: return sequence.first_round
        case 2: return sequence.second_round
        case 3: return sequence.third_round
        case 4: return sequence.fourth_round
        case 5: return sequence.fifth_round
        case 6: return sequence.sixth_round
        default: return nil
        }
    }
    
    func getGreenTypeId() -> Int64? {
        // Assuming round 2 is green/idea round
        return sequence?.second_round
    }
    
    // MARK: - Type Conversion
    
    func mapTypeToSessionRoom(typeName: String) -> SessionRoom {
        switch typeName.lowercased() {
        case "white": return .fact
        case "green": return .idea
        case "darker green": return .buildon
        case "yellow": return .benefit
        case "black": return .risk
        case "red": return .feeling
        default: return .fact
        }
    }
    
    func getMessageCardType(for typeId: Int64?) -> MessageCardType {
        guard let typeId = typeId, let sequence = sequence else { return .white }
        
        switch typeId {
        case sequence.first_round: return .white
        case sequence.second_round: return .green
        case sequence.third_round: return .darkGreen
        case sequence.fourth_round: return .yellow
        case sequence.fifth_round: return .black
        case sequence.sixth_round: return .red
        default: return .white
        }
    }
    
    // MARK: - Round State Checks
    
    func isCommentRound(typeId: Int64?) -> Bool {
        guard let typeId = typeId else { return false }
        return isDarkGreenType(typeId) || isYellowType(typeId) || isBlackType(typeId)
    }
    
    func isYellowType(_ typeId: Int64) -> Bool {
        return sequence?.fourth_round == typeId
    }
    
    func isBlackType(_ typeId: Int64) -> Bool {
        return sequence?.fifth_round == typeId
    }
    
    func isDarkGreenType(_ typeId: Int64) -> Bool {
        return sequence?.third_round == typeId
    }
    
    // MARK: - Round Advancement
    
    func hasNextRound(after currentRound: Int64) -> Bool {
        guard let sequence = sequence else { return false }
        
        let nextRound = currentRound + 1
        
        switch nextRound {
        case 1: return sequence.first_round != nil
        case 2: return sequence.second_round != nil
        case 3: return sequence.third_round != nil
        case 4: return sequence.fourth_round != nil
        case 5: return sequence.fifth_round != nil
        case 6: return sequence.sixth_round != nil
        default: return false
        }
    }
}

// MARK: - Errors

enum RoundManagerError: LocalizedError {
    case sequenceNotSet
    case noTypeForRound(Int64)
    
    var errorDescription: String? {
        switch self {
        case .sequenceNotSet:
            return "Sequence must be set before loading round type"
        case .noTypeForRound(let round):
            return "No type found for round \(round)"
        }
    }
}

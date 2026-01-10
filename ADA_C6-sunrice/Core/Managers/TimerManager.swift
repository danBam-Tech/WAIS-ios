//
//  TimerManager.swift
//  ADA_C6-sunrice
//
//  Created by Antigravity on 24/11/25.
//

import Combine
import Foundation

struct PollingAction {
    let id: String
    let action: () async -> Void
}

@MainActor
final class TimerManager {
    private let sessionService: SessionServicing
    private var roundTimer: AnyCancellable?
    
    // Unified polling system
    private var unifiedPollingTask: Task<Void, Never>?
    private var pollingActions: [String: () async -> Void] = [:]
    
    init(sessionService: SessionServicing) {
        self.sessionService = sessionService
    }
    
    // MARK: - Unified Polling System
    
    func startUnifiedPolling() {
        guard unifiedPollingTask == nil else { return }
        
        unifiedPollingTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self = self else { return }
                
                // Execute all registered polling actions
                for (id, action) in await self.pollingActions {
                    if !Task.isCancelled {
                        await action()
                    }
                }
                
                // Sleep for 1 second
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
    }
    
    func registerPollingAction(id: String, action: @escaping () async -> Void) {
        pollingActions[id] = action
        
        // Start unified polling if not already running
        if unifiedPollingTask == nil {
            startUnifiedPolling()
        }
    }
    
    func unregisterPollingAction(id: String) {
        pollingActions.removeValue(forKey: id)
        
        // Stop unified polling if no actions remain
        if pollingActions.isEmpty {
            stopUnifiedPolling()
        }
    }
    
    func unregisterAllPollingActions() {
        pollingActions.removeAll()
        stopUnifiedPolling()
    }
    
    private func stopUnifiedPolling() {
        unifiedPollingTask?.cancel()
        unifiedPollingTask = nil
    }
    
    // MARK: - Host Timer
    
    func startHostTimer(getDeadline: @escaping () -> Date, onTimeUp: @escaping () async -> Void) {
        cancelAllTimers()
        
        roundTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                let currentDeadline = getDeadline()
                if Date() >= currentDeadline {
                    self.roundTimer?.cancel()
                    
                    Task {
                        await onTimeUp()
                    }
                }
            }
    }
    
    // MARK: - Guest Timer
    
    func startGuestDeadlineTimer(getDeadline: @escaping () -> Date, onTimeUp: @escaping () async -> Void) {
        cancelAllTimers()
        
        roundTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                let currentDeadline = getDeadline()
                if Date() >= currentDeadline {
                    self.roundTimer?.cancel()
                    
                    Task {
                        await onTimeUp()
                    }
                }
            }
    }
    
    // MARK: - Round Polling (Guest)
    
    func startPollingRound(sessionId: Int64, currentRound: Int64, onRoundChange: @escaping (Int64) async -> Void) {
        var lastKnownRound = currentRound
        
        registerPollingAction(id: "round_polling") { [weak self] in
            guard let self = self else { return }
            
            do {
                let updatedSession = try await self.sessionService.fetchSession(id: sessionId)
                let newRound = updatedSession.current_round ?? 1
                
                if newRound != lastKnownRound {
                    lastKnownRound = newRound
                    await onRoundChange(newRound)
                }
            } catch {
                print("Error polling round: \(error)")
            }
        }
    }
    
    // MARK: - Deadline Extension
    
    func extendDeadline(by seconds: TimeInterval) -> Date {
        return Date().addingTimeInterval(seconds)
    }
    
    // MARK: - Cleanup
    
    // MARK: - Comment Polling
    
    func startPollingCommentCounts(action: @escaping () async -> Void) {
        registerPollingAction(id: "comment_counts", action: action)
    }
    
    func stopPollingCommentCounts() {
        unregisterPollingAction(id: "comment_counts")
    }

    // MARK: - Cleanup
    
    func cancelAllTimers() {
        roundTimer?.cancel()
        roundTimer = nil
        unregisterAllPollingActions()
    }
    
    // Nonisolated version for deinit
    nonisolated func cancelAllTimersFromDeinit() {
        Task { @MainActor [weak self] in
            self?.roundTimer?.cancel()
            self?.unifiedPollingTask?.cancel()
        }
    }
    
    deinit {
        cancelAllTimersFromDeinit()
    }
}

//
//  WebSocketManager.swift
//  ADA_C6-sunrice
//
//  Created by Tude Maha on 28/01/2026.
//

import Foundation
import Combine

@MainActor
final class WebSocketManager: ObservableObject {
    @Published var conversations = [ConversationDTO]()
    @Published var isConnected = false
    @Published var name = ""
    
    private var webSocketTask: URLSessionWebSocketTask?
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func connect(roomCode: String, name: String) {
        guard let url = URL(string: "wss://wais.tudemaha.my.id/rooms/ws?room_code=\(roomCode)&username=\(name)") else { return }
        self.name = name
        
        let request = URLRequest(url: url)
        webSocketTask = URLSession.shared.webSocketTask(with: request)
        webSocketTask?.resume()
        
        conversations.append(ConversationDTO(
            name: "system",
            message: "Connected",
            role: .system
        ))
        
        isConnected = true
        print("WebSocket connected")
        
        receiveMessage()
    }
    
    func disconnect() {
        webSocketTask?.cancel()
        
        conversations.append(ConversationDTO(
            name: "system",
            message: "Disconnected",
            role: .system
        ))
        
        isConnected = true
        print("WebSocket disconnected")
    }
    
    private func receiveMessage() {
        webSocketTask?.receive() { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let message):
                switch message {
                case .string(let message):
                    DispatchQueue.main.async {
                        if let jsonRes = message.data(using: .utf8) {
                            do {
                                let res = try self.decoder.decode(SocketResponse.self, from: jsonRes)
                                print("Received: \(res)")
                                
                                self.conversations.append(ConversationDTO(
                                    name: res.from,
                                    message: res.message,
                                    role:.receive)
                                )
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                default:
                    break
                }
                
                DispatchQueue.main.async {
                    self.receiveMessage()
                }
            }
        }
    }
    
    func sendRequest(_ request: SocketRequest) {
        do {
            let jsonReq = try encoder.encode(request)
            if let jsonString = String(data: jsonReq, encoding: .utf8) {
                print("Sent: \(jsonString)")
                webSocketTask?.send(.string(jsonString)) { error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    
                    DispatchQueue.main.async {
                        self.conversations.append(ConversationDTO(
                            name: self.name,
                            message: request.message,
                            role: .send)
                        )
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

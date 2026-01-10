//
//  NavigationViewModel.swift
//  ADA_C6-sunrice
//
//  Created by Komang Wikananda on 04/11/25.
//

import SwiftUI
import Combine

class NavigationViewModel: ObservableObject {
    @Published var path = NavigationPath()
    
    func goToCreateSession() {
        path.append(Route.create)
    }
    
    func goToJoinSession() {
        path.append(Route.join)
    }
    
    func goToSessionLobby(id: Int64) {
        path.append(Route.session(id: String(id), isHost: false))
    }
    
    func goToSession(id: Int64) {
        path.append(Route.session(id: String(id), isHost: false))
    }
    
    func goToSessionRoom(id: Int64, isHost: Bool) {
        path.append(Route.session(id: String(id), isHost: isHost))
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
}

//
//  Game.swift
//  ParticleWar
//
//  Created by Lawrence Bensaid on 10/16/22.
//

import SwiftUI

class Game: ObservableObject {
    
    @Published public private(set) var scene: GameScene?
    
    @Published public private(set) var state: GameState = .mainMenu
    @Published public private(set) var isPaused = true
    
    @Published public var time = 0.0
    @Published public var sim = 0.0
    
    func start() {
        scene = GameScene.initialize(self)
        isPaused = false
        state = .inGame
    }
    
    func end(reason: EndReason) {
        scene?.isPaused = true
        isPaused = true
        state = .gameOver(reason)
    }
    
    func reset() {
        isPaused = true
        scene = nil
        state = .mainMenu
        time = 0
    }
    
    func pause() {
        scene?.isPaused = true
        isPaused = true
    }
    
    func unpause() {
        scene?.isPaused = false
        isPaused = false
    }
    
}

enum GameState: Equatable {
    case mainMenu, inGame, gameOver(EndReason)
}

enum EndReason: Int {
    case won, lost
}

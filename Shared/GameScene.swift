//
//  GameScene.swift
//  ParticleWar
//
//  Created by Lawrence Bensaid on 10/16/22.
//

import SpriteKit
import SwiftUI

class GameScene: SKScene, ObservableObject {
    
    // Camera
    internal var previousCameraScale: CGFloat = 1
    internal var previousCameraPoint: CGPoint = .zero
    internal let cameraNode = SKCameraNode()
    internal var previousDragPoint: CGPoint = .zero
    
    // UI
    internal var sourceTouch: CGPoint?
    internal var targetTouch: CGPoint?
    internal let dragLine = SKShapeNode()
    internal var rangeIndicators: [Client: RangeIndicator] = [:]
    
    // Engine
    private var lastUpdateTime = 0.0
    
    // Game
    public var game: Game!
    public var territories: [SKNode: Territory] = [:]
    public var armies: [SKNode: Army] = [:]
    
    public var level: Level?

    class func initialize(_ game: Game) -> GameScene {
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else { print("Failed to load GameScene.sks"); abort() }
        scene.scaleMode = .aspectFill
        scene.game = game
        scene.speed = 2
        return scene
    }
    
    func setUpScene() {
        
        getLevel()
        
        loadLevel()
        
    }
    
    override func didMove(to view: SKView) {
        
        camera = cameraNode
        
        setUpScene()
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 { lastUpdateTime = currentTime } // Initial set time
        let fps = 1 / (currentTime - lastUpdateTime)
        lastUpdateTime = currentTime
        game.sim = fps / 60 * speed
        game.time += 1 / 60 * speed
        
        for bot in self.level?.bots ?? [] {
            bot.update()
        }
        
        for node in children {
            if let tower = territories[node] {
                tower.update()
            }
            if let army = armies[node] {
                guard let target = army.target else { continue }
                if army.node.intersects(target.node) {
                    target.receive(army)
                    continue
                }
                let speed: CGFloat = 1
                let x = target.position.x - army.position.x
                let y = target.position.y - army.position.y
                let angle = atan2(y, x)
                let vx = cos(angle) * speed
                let vy = sin(angle) * speed
                army.position.x += vx
                army.position.y += vy
            }
        }
        
        if level?.player?.ownTerritories.count == level?.player?.territories.count {
            game.end(reason: .won)
        }
        if level?.player?.ownTerritories.count == 0 {
            game.end(reason: .lost)
        }
        
    }
    
}

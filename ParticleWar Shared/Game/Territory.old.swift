//
//  Territory.swift
//  DotWars iOS
//
//  Created by Lawrence Bensaid on 2/8/22.
//

import SpriteKit
import GameplayKit

class Territory: SKShapeNode {
    
    public internal(set) var team: Team?
    var armies: Int = 10
    var mana: Double = 0
    var factory: Int = 20
    var capacity: Int = 50
    var attacking = false
    public let deploymentSpeed = 0.25
    public let productionSpeed = 0.01
    public let range: Double = 200
    
    internal var context: GameScene?
    private let label = SKLabelNode(text: "")
    
    convenience init(team: Team? = nil, position: CGPoint? = nil, context: GameScene) {
        self.init()
        self.team = team
        self.context = context
        self.position = position ?? .zero
        fillColor = team?.color ?? .lightGray
    }
    
    override init() {
        super.init()
        path = CGPath(roundedRect: CGRect(x: -25, y: -25, width: 50, height: 50), cornerWidth: 25, cornerHeight: 25, transform: nil)
        lineWidth = 0
        name = "\(team?.name ?? "unnamed") Territory"
        label.text = "\(Int(armies))"
        label.position = .init(x: 0, y: -54)
        label.fontSize = 16
        label.fontName = "Helvetica Neue Bold"
        addChild(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func attack(_ territory: Territory) {
        guard attacking else { return }
        guard armies > 0 else { attacking = false; return }
        context?.deployArmy(from: self, to: territory)
        armies -= 1
        DispatchQueue.main.asyncAfter(deadline: .now() + deploymentSpeed) {
            self.attack(territory)
        }
    }
    
    public func distance(to land: Territory) -> Double {
        position.distance(to: land.position)
    }
    
    public func set(team: Team?) {
        self.team = team
        fillColor = team?.color ?? .lightGray
        name = "\(team?.name ?? "unnamed") Territory"
    }
    
    public func update() {
        if team != nil && armies < factory {
            mana += productionSpeed
        }
        if mana >= 1 {
            mana -= 1
            armies += 1
        }
        if team == Game.main.player?.team {
            label.text = "\(Int(armies))/\(capacity)"
        } else {
            label.text = "\(Int(armies))"
        }
    }
    
    public func receive(_ army: Army) {
        run(SKAction(named: "Pulse")!)
        if team == army.team {
            armies += 1
            if team == Game.main.player?.team {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            }
        } else {
            armies -= 1
            if team == Game.main.player?.team {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
            if armies <= 0 {
                set(team: army.team)
            }
        }
        army.removeFromParent()
    }
    
    public func launchAttack(on territory: Territory) {
        if distance(to: territory) <= range {
            attacking = true
            attack(territory)
        }
    }
    
}

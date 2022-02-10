//
//  Territory.swift
//  ParticleWar iOS
//
//  Created by Lawrence Bensaid on 2/8/22.
//

import SpriteKit
import GameplayKit

class Territory: Hashable {
    
    public static func == (lhs: Territory, rhs: Territory) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    private let id = UUID()
    public internal(set) var team: Team?
    var armies: Int = 10
    var mana: Double = 0
    var factory: Int = 20
    var capacity: Int = 50
    var attacking = false
    public let deploymentSpeed = 0.25
    public let productionSpeed = 0.01
    public let range: Double = 200
    
    internal var context: GameScene
    private let label = SKLabelNode(text: "")
    
    // Proxy
    public let node = SKShapeNode()
    public internal(set) var name: String {
        get { node.name ?? "\(team?.name ?? "unnamed") Territory" }
        set { node.name = newValue }
    }
    public var position: CGPoint {
        get { node.position }
        set { node.position = newValue }
    }
    public var lineWidth: CGFloat {
        get { node.lineWidth }
        set { node.lineWidth = newValue }
    }
    public var color: SKColor? {
        get { node.fillColor }
        set { node.fillColor = newValue ?? .lightGray }
    }
    public var path: CGPath? {
        get { node.path }
        set { node.path = newValue }
    }
    public var strokeColor: SKColor {
        get { node.strokeColor }
        set { node.strokeColor = newValue }
    }
    
    init(team: Team? = nil, context: GameScene) {
        self.team = team
        self.context = context
        color = team?.color.withAlphaComponent(0.8)
        
        node.path = CGPath(roundedRect: CGRect(x: -25, y: -25, width: 50, height: 50), cornerWidth: 25, cornerHeight: 25, transform: nil)
        node.lineWidth = 0
        name = "\(team?.name ?? "unnamed") Territory"
        label.text = "\(Int(armies))"
        label.position = .init(x: 0, y: -54)
        label.fontSize = 16
        label.fontName = "Helvetica Neue Bold"
        node.addChild(label)
    }
    
    private func attack(_ territory: Territory) {
        guard attacking else { return }
        guard armies > 0 else { attacking = false; return }
        context.deployArmy(from: self, to: territory)
        armies -= 1
        DispatchQueue.main.asyncAfter(deadline: .now() + deploymentSpeed) {
            self.attack(territory)
        }
    }
    
    public func supply(to territory: Territory) {
        context.deployHighway(from: self, to: territory)
    }
    
    public func distance(to land: Territory) -> Double {
        node.position.distance(to: land.node.position)
    }
    
    public func set(team: Team?) {
        self.team = team
        color = team?.color.withAlphaComponent(0.8)
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
        node.run(SKAction(named: "Pulse")!)
        if team == army.team {
            armies += 1
            if team == Game.main.player?.team {
#if os(iOS)
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
#endif
            }
        } else {
            armies -= 1
            if team == Game.main.player?.team {
#if os(iOS)
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
#endif
            }
            if armies <= 0 {
                set(team: army.team)
            }
        }
        army.die()
    }
    
    public func launchAttack(on territory: Territory) {
        if distance(to: territory) <= range {
            attacking = true
            attack(territory)
        }
    }

}

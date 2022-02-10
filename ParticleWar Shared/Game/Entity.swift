//
//  Entity.swift
//  ParticleWar
//
//  Created by Lawrence Bensaid on 2/9/22.
//

import SpriteKit

class Entity: Hashable {
    
    public static func == (lhs: Entity, rhs: Entity) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    internal let id = UUID()
    public internal(set) var team: Team?
    
    internal var context: GameScene
    
    // Proxy
    public let node = SKShapeNode()
    public internal(set) var name: String {
        get { node.name ?? "\(team?.name ?? "unnamed") Entity" }
        set { node.name = newValue }
    }
    public var position: CGPoint {
        get { node.position }
        set { node.position = newValue }
    }
    
    internal init(team: Team? = nil, context: GameScene) {
        self.context = context
        self.team = team
        self.name = "\(team?.name ?? "unnamed") Entity"
    }
    
}

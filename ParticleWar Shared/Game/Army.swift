//
//  Army.swift
//  ParticleWar iOS
//
//  Created by Lawrence Bensaid on 2/8/22.
//

import SpriteKit

class Army: Entity {
    
    public private(set) var target: Territory?
    
    init(team: Team?, target: Territory? = nil, context: GameScene) {
        super.init(team: team, context: context)
        self.target = target
        node.path = .init(roundedRect: CGRect(x: -8, y: -8, width: 16, height: 16), cornerWidth: 4, cornerHeight: 4, transform: nil)
        node.strokeColor = team?.color ?? .lightGray
        node.lineWidth = 4
        node.run(SKAction.repeatForever(.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
        name = "\(team?.name ?? "unnamed") Army"
    }
    
    public required convenience init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    public func die() {
        context?.armies.removeValue(forKey: node)
        node.removeFromParent()
    }
    
}

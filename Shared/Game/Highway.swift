//
//  Highway.swift
//  ParticleWar
//
//  Created by Lawrence Bensaid on 2/9/22.
//

import SpriteKit

class Highway: Hashable {
    
    public static func == (lhs: Highway, rhs: Highway) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    private let id = UUID()
    
    // Proxy
    public let node = SKShapeNode()
    
    public private(set) var origin: Territory?
    public private(set) var target: Territory?
    
    init(origin: Territory, target: Territory) {
        self.origin = origin
        self.target = target
        node.lineWidth = 8
        node.strokeColor = origin.team?.color ?? .lightGray
        let path = CGMutablePath()
        path.move(to: origin.position)
        path.addLine(to: target.position)
        node.path = path
    }
    
}

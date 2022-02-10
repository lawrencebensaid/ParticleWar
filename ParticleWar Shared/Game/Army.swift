//
//  Army.swift
//  DotWars iOS
//
//  Created by Lawrence Bensaid on 2/8/22.
//

import SpriteKit

class Army: SKShapeNode {
    
    public private(set) var team: Team?
    public private(set) var origin: Territory?
    public private(set) var target: Territory?
    
    convenience init(origin: Territory? = nil, target: Territory? = nil) {
        let scale: CGFloat = 16
        self.init(rectOf: CGSize(width: scale, height: scale))
        self.team = origin?.team
        self.origin = origin
        self.target = target
        let p = -(scale / 2)
        let rect = CGRect(x: p, y: p, width: scale, height: scale)
        self.path = .init(roundedRect: rect, cornerWidth: scale * 0.25, cornerHeight: scale * 0.25, transform: nil)
        self.position = origin?.position ?? .zero
        self.strokeColor = team?.color ?? .lightGray
        self.lineWidth = 4.0
        self.run(SKAction.repeatForever(.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
        self.name = "\(team?.name ?? "unnamed") Army"
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

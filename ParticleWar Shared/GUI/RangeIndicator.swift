//
//  RangeIndicator.swift
//  DotWars
//
//  Created by Lawrence Bensaid on 2/9/22.
//

import SpriteKit

class RangeIndicator: SKShapeNode {
    
    override init() {
        super.init()
        position = .zero
        zPosition = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func size(_ value: Double) {
        path = CGPath(ellipseIn: CGRect(origin: .init(x: -value, y: -value), size: .init(width: value * 2, height: value * 2)), transform: nil)
        lineWidth = 2
    }
    
    public func color(_ value: UIColor) {
        fillColor = value.withAlphaComponent(0.1)
        strokeColor = value.withAlphaComponent(0.7)
    }
    
}

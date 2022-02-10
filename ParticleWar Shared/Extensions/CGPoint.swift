//
//  CGPoint.swift
//  ParticleWar
//
//  Created by Lawrence Bensaid on 2/8/22.
//

import CoreGraphics

extension CGPoint {
    
    public func distance(to target: CGPoint) -> Double {
        let deltaX = x - target.x
        let deltaY = y - target.y
        return sqrt(deltaX * deltaX + deltaY * deltaY)
    }
    
}

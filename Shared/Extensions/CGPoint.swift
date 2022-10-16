//
//  CGPoint.swift
//  ParticleWar
//
//  Created by Lawrence Bensaid on 2/8/22.
//

import SpriteKit

extension CGPoint: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        let a = x >= 0 ? 2 * x : -2 * x - 1;
        let b = y >= 0 ? 2 * y : -2 * y - 1;
        hasher.combine(a >= b ? a * a + a + b : a + b * b)
    }
    
    public func distance(to target: CGPoint) -> Double {
        let deltaX = x - target.x
        let deltaY = y - target.y
        return sqrt(deltaX * deltaX + deltaY * deltaY)
    }
    
    public func distances(of points: [CGPoint], inRange range: Double? = nil) -> [CGPoint: Double] {
        var distances: [CGPoint: Double] = [:]
        for point in points {
            let distance = distance(to: point)
            if range == nil || distance <= range! {
                distances[point] = distance
            }
        }
        return distances
    }
    
    public func nearest(_ points: [CGPoint], inRange range: Double? = nil) -> [CGPoint] {
        var result: [CGPoint] = []
        for point in distances(of: points, inRange: range).sorted(by: { $0.value < $1.value }) {
            guard point.key != self else { continue }
            result.append(point.key)
        }
        return result
    }
    
}

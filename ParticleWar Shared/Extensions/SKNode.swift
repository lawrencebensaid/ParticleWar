//
//  SKNode.swift
//  DotWars
//
//  Created by Lawrence Bensaid on 2/9/22.
//

import SpriteKit

extension SKNode {
    
    public func distances(of nodes: [SKNode], inRange range: Double? = nil) -> [SKNode: Double] {
        var distances: [SKNode: Double] = [:]
        for node in nodes {
            let distance = position.distance(to: node.position)
            if range == nil || distance <= range! {
                distances[node] = distance
            }
        }
        return distances
    }
    
    public func nearest(_ nodes: [SKNode], inRange range: Double? = nil) -> [SKNode] {
        var result: [SKNode] = []
        for point in distances(of: nodes, inRange: range).sorted(by: { $0.value < $1.value }) {
            guard point.key != self else { continue }
            result.append(point.key)
        }
        return result
    }
    
}

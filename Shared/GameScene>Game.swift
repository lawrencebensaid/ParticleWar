//
//  GameScene>Game.swift
//  ParticleWar
//
//  Created by Lawrence Bensaid on 10/16/22.
//

import SpriteKit

extension GameScene {
    
    internal func add(_ territory: Territory, at position: CGPoint? = nil) {
        if let position = position {
            territory.position = position
        }
        territories[territory.node] = territory
        super.addChild(territory.node)
    }
    
    public func highlight(_ territory: Territory, by client: Client) {
        if rangeIndicators[client] == nil {
            let indicator = RangeIndicator()
            rangeIndicators[client] = indicator
            addChild(indicator)
        }
        let indicator = rangeIndicators[client]
        indicator?.size(territory.range)
        indicator?.color(territory.team?.color ?? .lightGray)
        indicator?.position = territory.position
    }
    
    public func resetHighlight(_ client: Client) {
        rangeIndicators[client]?.removeFromParent()
        rangeIndicators.removeValue(forKey: client)
    }
    
    public func deployArmy(from origin: Territory, to target: Territory) {
        let army = Army(team: origin.team, target: target, context: self)
        army.position = origin.position
        armies[army.node] = army
        super.addChild(army.node)
    }
    
    public func deployHighway(from origin: Territory, to target: Territory) {
        let highway = Highway(origin: origin, target: target)
        super.addChild(highway.node)
    }
    
}

//
//  Bot.swift
//  DotWars
//
//  Created by Lawrence Bensaid on 2/8/22.
//

import SpriteKit

class Bot {
    
    public let client: Client
    
    public var cycle: Int = 0
    public let cooldown = 20
    
    private var nodes: [SKNode] { client.context?.children ?? [] }
    private var territories: [Territory] { nodes.compactMap({ client.context?.territories[$0] }) }
    private var ownTerritories: [Territory] { territories.filter { $0.team == client.team } }
    private var otherTerritories: [Territory] { territories.filter { $0.team != client.team } }
    
    private var borderTerritories: [Territory] { ownTerritories.filter { $0.node.nearest(otherTerritories.map { $0.node }, inRange: $0.range).count > 0 } }
    private var innerTerritories: [Territory] { ownTerritories.filter { $0.node.nearest(otherTerritories.map { $0.node }, inRange: $0.range).count <= 0 } }
    
    public init(client: Client) {
        self.client = client
    }
    
    public func update() {
        guard cycle <= 0 else { cycle -= 1; return }
        cycle = cooldown
        guard nodes.count > 0 else { return }
        for territory in ownTerritories {
            guard territory.armies > 0 else { continue }
            if client.selected != nil {
                if let nearest = territory.node.nearest(otherTerritories.map { $0.node }, inRange: territory.range).first {
                    client.tap(nearest.position)
                } else if innerTerritories.contains(territory),
                          let nearest = territory.node.nearest(borderTerritories.map { $0.node }, inRange: territory.range).first,
                          nearest != client.selected?.node {
//                    print("REINFORCE \(client.selected!.position) > \(nearest.position)")
                    client.tap(nearest.position)
                }
            }
            if client.selected == nil {
                client.tap(territory.position)
            }
        }
    }
    
}

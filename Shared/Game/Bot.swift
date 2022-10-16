//
//  Bot.swift
//  ParticleWar
//
//  Created by Lawrence Bensaid on 2/8/22.
//

import SpriteKit

class Bot: Codable {
    
    public enum Tactic {
        case pushing
        case defending
    }
    
    public enum Difficulty: String {
        case easy = "easy"
        case normal = "normal"
        case hard = "hard"
    }
    
    // Temp
    private var teamAssign: String?
    
    // Characteristics
    public let name: String
    public let difficulty: Difficulty
    public let cooldown: Int
    
    // Statistics
    private var borderTerritories: [Territory] {
        guard let client = client else { return [] }
        return client.ownTerritories.filter {
            $0.node.nearest(client.otherTerritories.map { $0.node }, inRange: $0.range).count > 0
        }
    }
    private var innerTerritories: [Territory] {
        guard let client = client else { return [] }
        return client.ownTerritories.filter {
            $0.node.nearest(client.otherTerritories.map { $0.node }, inRange: $0.range).count <= 0
        }
    }
    
    // Context
    public let client: Client?
    
    // State
    public var cycle: Int = 0
    public var tactic: Tactic = .pushing
    
    private enum CodingKeys: CodingKey {
        case name, team, difficulty
    }
    
    public init(client: Client?, name: String? = nil, difficulty: Difficulty? = nil) {
        self.client = client
        self.name = name ?? "Bot"
        self.difficulty = difficulty ?? .normal
        switch self.difficulty {
        case .easy:
            cooldown = 50
        case .normal:
            cooldown = 20
        case .hard:
            cooldown = 25
        }
    }
    
    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decodeIfPresent(String.self, forKey: .name)
        let team = try container.decode(String.self, forKey: .team)
        let difficulty = try container.decodeIfPresent(String.self, forKey: .difficulty)
        self.init(client: nil, name: name, difficulty: Difficulty(rawValue: difficulty ?? "normal"))
        self.teamAssign = team
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
    }
    
    public func update() {
        guard let client = client else { return }
        guard cycle <= 0 else { cycle -= 1; return }
        cycle = cooldown
        switch difficulty {
        case .easy: updateEasy(client)
        case .normal: updateNormal(client)
        case .hard: updateHard(client)
        }
    }
    
    private func updateEasy(_ client: Client) {
        for territory in client.ownTerritories {
            guard territory.armies > 0 else { continue }
            if client.selected != nil {
                if let nearest = territory.node.nearest(client.otherTerritories.map { $0.node }, inRange: territory.range).first {
                    client.tap(nearest.position)
                }
            }
            if client.selected == nil {
                client.tap(territory.position)
            }
        }
    }
    
    private func updateNormal(_ client: Client) {
        for territory in client.ownTerritories {
            guard territory.armies > 0 else { continue }
            if client.selected != nil {
                if let nearest = territory.node.nearest(client.otherTerritories.map { $0.node }, inRange: territory.range).first {
                    client.tap(nearest.position)
                } else if innerTerritories.contains(territory),
                          let nearest = territory.node.nearest(borderTerritories.map { $0.node }, inRange: territory.range).first,
                          nearest != client.selected?.node {
                    client.tap(nearest.position)
                }
            }
            if client.selected == nil {
                client.tap(territory.position)
            }
        }
    }
    
    private func updateHard(_ client: Client) {
        for territory in client.ownTerritories {
            guard territory.armies > 0 else { continue }
            if client.selected != nil {
                if let nearest = territory.node.nearest(client.otherTerritories.map { $0.node }, inRange: territory.range).first {
                    client.tap(nearest.position)
                } else if innerTerritories.contains(territory),
                          let nearest = territory.node.nearest(borderTerritories.map { $0.node }, inRange: territory.range).first,
                          nearest != client.selected?.node {
                    client.tap(nearest.position)
                }
            }
            if client.selected == nil {
                client.tap(territory.position)
            }
        }
    }
    
}

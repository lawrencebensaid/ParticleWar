//
//  Entity.swift
//  ParticleWar
//
//  Created by Lawrence Bensaid on 2/9/22.
//

import SpriteKit

class Entity: NSObject, Codable {
    
    internal let id = UUID()
    public internal(set) var team: Team?
    
    internal var context: GameScene?
    
    // Proxy
    public let node = SKShapeNode()
    public internal(set) var name: String {
        get { node.name ?? "\(team?.name ?? "unnamed") Entity" }
        set { node.name = newValue }
    }
    public var position: CGPoint {
        get { node.position }
        set { node.position = newValue }
    }
    
    internal init(name: String? = nil, team: Team? = nil, context: GameScene) {
        super.init()
        self.name = name ?? "\(team?.name ?? "unnamed") Entity"
        self.team = team
        self.context = context
    }
    
    private enum CodingKeys: CodingKey {
        case name, team
    }
    
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.context] as? GameScene else { fatalError() }
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var team = try container.decodeIfPresent(Team.self, forKey: .team)
        let name = try container.decodeIfPresent(String.self, forKey: .name)
        if team == nil, let teamName = try container.decodeIfPresent(String.self, forKey: .team) {
            team = context.level?.getTeamBy(name: teamName)
        }
        self.init(name: name, team: team, context: context)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(team?.name, forKey: .team)
    }
    
}

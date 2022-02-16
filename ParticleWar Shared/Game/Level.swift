//
//  Level.swift
//  ParticleWar
//
//  Created by Lawrence Bensaid on 2/10/22.
//

import Foundation

class Level: NSObject, Codable {
    
    public var scene: GameScene?
    public var player: Client?
    public var bots: [Bot] = []
    
    public var teams: [Team] = []
    public var structures: [Territory] = []
//    public let entities: [Entity]
    
    override var description: String {
        "s: \(structures.description);"
    }
    
    private enum CodingKeys: CodingKey {
        case bots, teams, structures, entities
    }
    
    private override init() {
        structures = []
        teams.append(Team("Red", color: .red))
        teams.append(Team("Blue", color: .blue))
        teams.append(Team("Green", color: .green))
        teams.append(Team("Yellow", color: .yellow))
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        teams = try container.decode([Team].self, forKey: .teams)
        structures = (try container.decode([StructureContainer].self, forKey: .structures)).map { $0.structure }
//        entities = try container.decode([Entity].self, forKey: .entities)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(teams, forKey: .teams)
        try container.encode(structures.map { StructureContainer($0) }, forKey: .structures)
//        try container.encode(entities, forKey: .entities)
    }
    
    public func register(_ scene: GameScene) {
        self.scene = scene
    }
    
    public func set(player: Client) {
        if let scene = scene {
            player.register(scene)
            self.player = player
        }
    }
    
    public func add(bot: Bot) {
        if let scene = scene {
            bot.client?.register(scene)
            bots.append(bot)
        }
    }
    
    public func getTeamBy(name: String) -> Team? {
        return teams.filter({ $0.name == name }).first
    }
    
}

fileprivate struct StructureContainer: Codable {
    
    let structure: Territory
    
    private enum CodingKeys: CodingKey {
        case type, structure
    }
    
    init(_ structure: Territory) {
        self.structure = structure
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "HomeTerritory":
            structure = try container.decode(HomeTerritory.self, forKey: .structure)
        default:
            structure = try container.decode(Territory.self, forKey: .structure)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(structure, forKey: .structure)
        try container.encode(String.init(describing: Swift.type(of: structure)), forKey: .type)
    }
    
}

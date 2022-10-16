//
//  Team.swift
//  ParticleWar
//
//  Created by Lawrence Bensaid on 2/8/22.
//

import SpriteKit

class Team: Codable, Identifiable, ObservableObject, Equatable {
    
    public static func == (lhs: Team, rhs: Team) -> Bool {
        lhs.name == rhs.name
    }
    
    public var id = UUID()
    
    // Characteristics
    public let name: String
    public let color: SKColor
    
    // Statistics
    public var score: Int {
        var score: Int = 0
        for (_, value) in context?.territories ?? [:] {
            if value.team != self { continue }
            score += value.armies
        }
        return score
    }
    
    // Context
    internal var context: GameScene?
    
    private enum CodingKeys: CodingKey {
        case name
        case color
    }
    
    init(_ name: String, color: SKColor, context: GameScene? = nil) {
        self.name = name
        self.color = color
        self.context = context
    }
    
    public required convenience init(from decoder: Decoder) throws {
        let context = decoder.userInfo[.context] as? GameScene
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let hex = try container.decode(String.self, forKey: .color)
        self.init(name, color: SKColor(hex: hex), context: context)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(color.hex, forKey: .color)
    }
    
}

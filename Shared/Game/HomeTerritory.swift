//
//  HomeTerritory.swift
//  ParticleWar
//
//  Created by Lawrence Bensaid on 2/8/22.
//

import CoreGraphics

class HomeTerritory: Territory {
    
    public override init(name: String? = nil, team: Team? = nil, context: GameScene? = nil) {
        super.init(name: name, team: team, context: context)
        var transform = CGAffineTransform(rotationAngle: 45 * .pi / 180)
        path = CGPath(roundedRect: CGRect(x: -25, y: -25, width: 50, height: 50), cornerWidth: 12, cornerHeight: 12, transform: &transform)
    }
    
    public required convenience init(from decoder: Decoder) throws {
        let context = decoder.userInfo[.context] as? GameScene
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decodeIfPresent(String.self, forKey: .name)
        let team = try container.decodeIfPresent(String.self, forKey: .team)
        self.init(name: name, context: context)
        self.teamAssign = team
        position = try container.decode(CGPoint.self, forKey: .position)
        if let armies = try container.decodeIfPresent(Int.self, forKey: .armies) {
            self.armies = armies
        }
    }
    
}

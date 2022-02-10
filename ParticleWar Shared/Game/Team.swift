//
//  Team.swift
//  DotWars iOS
//
//  Created by Lawrence Bensaid on 2/8/22.
//

import SpriteKit

class Team: Equatable {
    
    public static func == (lhs: Team, rhs: Team) -> Bool {
        lhs.name == rhs.name
    }
    
    public static let red = Team("Red", color: .red)
    public static let blue = Team("Blue", color: .blue)
    public static let green = Team("Green", color: .green)
    public static let yellow = Team("Yellow", color: .yellow)
    public static let all: [Team] = [.red, .yellow, .green, .blue]
    
    public let name: String
    public let color: UIColor
    
    private init(_ name: String, color: UIColor) {
        self.name = name
        self.color = color
    }
    
}

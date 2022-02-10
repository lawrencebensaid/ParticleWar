//
//  HomeTerritory.swift
//  DotWars
//
//  Created by Lawrence Bensaid on 2/8/22.
//

import Foundation
import UIKit

class HomeTerritory: Territory {
    
    override init(team: Team? = nil, position: CGPoint? = nil, context: GameScene) {
        super.init(team: team, position: position, context: context)
        var transform = CGAffineTransform(rotationAngle: 45 * .pi / 180)
        path = CGPath(roundedRect: CGRect(x: -25, y: -25, width: 50, height: 50), cornerWidth: 12, cornerHeight: 12, transform: &transform)
    }

}

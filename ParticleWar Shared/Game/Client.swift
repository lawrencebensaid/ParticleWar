//
//  Client.swift
//  DotWars
//
//  Created by Lawrence Bensaid on 2/8/22.
//

import UIKit
import SpriteKit

class Client: Hashable {
    
    public static func == (lhs: Client, rhs: Client) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Characteristics
    private let id = UUID()
    public let team: Team
    public let showActions: Bool
    
    // State
    public private(set) var context: GameScene?
    public var selected: Territory?
    
    init(_ team: Team, showActions: Bool = false) {
        self.team = team
        self.showActions = showActions
    }
    
    private func select(_ territory: Territory) {
        if showActions {
            territory.lineWidth = 8
            territory.strokeColor = team.color
        }
        selected = territory
        if team == Game.main.player?.team {
            context?.highlight(territory, by: self)
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
    
    private func unselect() {
        if showActions {
            selected?.lineWidth = 0
        }
        self.selected = nil
        if team == Game.main.player?.team {
            context?.resetHighlight(self)
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
    
    public func register(_ context: GameScene) {
        self.context = context
    }
    
    public func tap(_ point: CGPoint) {
        guard let territory = context?.nodes(at: point).compactMap({ context?.territories[$0] }).first else { unselect(); return }
        if let selected = selected {
            guard selected.distance(to: territory) <= territory.range else { unselect(); return }
            if selected.team == team && selected != territory {
                selected.launchAttack(on: territory)
            }
            unselect()
        } else {
            // Select
            select(territory)
        }
    }
    
    public func drag(from origin: CGPoint, to target: CGPoint) {
        guard let originTerritory = context?.nodes(at: origin).first else { return }
        guard let targetTerritory = context?.nodes(at: target).first else { return }
        print("DRAG from '\(originTerritory.name ?? "")' to '\(targetTerritory.name ?? "")'")
    }
    
}

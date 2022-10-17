//
//  Client.swift
//  ParticleWar
//
//  Created by Lawrence Bensaid on 2/8/22.
//

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
    
    // Statistics
    private var nodes: [SKNode] { context?.children ?? [] }
    public var territories: [Territory] { nodes.compactMap({ context?.territories[$0] }) }
    public var ownTerritories: [Territory] { territories.filter { $0.team == team } }
    public var otherTerritories: [Territory] { territories.filter { $0.team != team } }
    public var armyCount: Int { ownTerritories.reduce(0) { $0 + $1.armies } }
    public var capacity: Int { ownTerritories.reduce(0) { $0 + $1.capacity } }
    
    // Context
    public private(set) var context: GameScene?
    
    // State
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
        if team == context?.level?.player?.team {
            context?.highlight(territory, by: self)
#if os(iOS)
            UISelectionFeedbackGenerator().selectionChanged()
#endif
        }
    }
    
    private func unselect() {
        if showActions {
            selected?.lineWidth = 0
        }
        self.selected = nil
        if team == context?.level?.player?.team {
            context?.resetHighlight(self)
#if os(iOS)
            UISelectionFeedbackGenerator().selectionChanged()
#endif
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
                unselect()
                selected.launchAttack(on: territory)
            } else {
                unselect()
                select(territory)
            }
        } else {
            select(territory)
        }
    }
    
    public func drag(from origin: CGPoint, to target: CGPoint) {
        guard let originTerritory = context?.nodes(at: origin).compactMap({ context?.territories[$0] }).first else { return }
        guard let targetTerritory = context?.nodes(at: target).compactMap({ context?.territories[$0] }).first else { return }
        print("DRAG from '\(originTerritory.name)' to '\(targetTerritory.name)'")
        if originTerritory.team == team && targetTerritory.team == team {
//            originTerritory.supply(to: targetTerritory)
        }
    }
    
}

//
//  GameScene>LoadLevel.swift
//  ParticleWar
//
//  Created by Lawrence Bensaid on 10/16/22.
//

import SpriteKit

extension GameScene {
    
    internal func getLevel() {
        let levelNames = ["level2", "level"]
        let index = UserDefaults.standard.integer(forKey: "level_id")
        guard let path = Bundle.main.path(forResource: levelNames[index], ofType: "json") else { fatalError("File not found") }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe) else { fatalError("File not readable") }
        let decoder = JSONDecoder()
        print("Loading level '\(path)' (\(index))")
        decoder.userInfo = [.context: self]
        guard let level = try? decoder.decode(Level.self, from: data) else { fatalError("Decode failure") }
        self.level = level
    }
    
    internal func loadLevel() {
        guard let level = level else { return }
        level.register(self)
        level.set(player: Client(level.getTeamBy(name: "Blue")!, showActions: true))
//        if UserDefaults.standard.bool(forKey: "enabled_preference") == true {
            level.add(bot: Bot(client: Client(level.getTeamBy(name: "Red")!, showActions: true)))
            level.add(bot: Bot(client: Client(level.getTeamBy(name: "Yellow")!, showActions: true)))
            level.add(bot: Bot(client: Client(level.getTeamBy(name: "Green")!, showActions: true)))
//        }
        
        for structure in level.structures {
            add(structure)
        }
    }
    
}

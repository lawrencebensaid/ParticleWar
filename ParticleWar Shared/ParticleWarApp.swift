//
//  ParticleWarApp.swift
//  Shared
//
//  Created by Lawrence Bensaid on 2/14/22.
//

import SwiftUI
import SpriteKit

@main
struct ParticleWarApp: App {
    
    @State private var scene: GameScene = GameScene.newGameScene()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @State private var teams: [Team] = []
    
    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .top) {
                SpriteView(scene: scene)
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(teams) { team in
                            Label("\(team.name) \(team.score)", systemImage: "circle.circle.fill")
                                .foregroundColor(Color(team.color))
                        }
                    }
                    .padding()
                    Spacer()
                    VStack(alignment: .leading, spacing: 4) {
                        let client = scene.level?.player
                        Label("\(client?.ownTerritories.count ?? 0)", systemImage: "circle.fill")
                        Label("\(client?.armyCount ?? 0)/\(client?.capacity ?? 0)", systemImage: "diamond")
                    }
                    .padding(.top, 16)
                    .padding([.top, .trailing], 8)
                }
            }
            .edgesIgnoringSafeArea(.all)
            .onReceive(timer) { _ in
                withAnimation {
                    teams = (scene.level?.teams ?? []).sorted(by: { $0.score > $1.score })
                }
            }
        }
    }
    
}

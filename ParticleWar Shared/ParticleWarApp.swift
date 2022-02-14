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
    
    private let scene: GameScene = GameScene.newGameScene()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @State private var teams: [Team] = []
    
    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .topLeading) {
                SpriteView(scene: scene)
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(teams.sorted(by: { $0.score > $1.score }), id: \.name) { x in
                        HStack {
                            Image(systemName: "circle.circle.fill")
                            Text("\(x.name)")
                        }
                        .foregroundColor(Color(x.color))
                    }
                }
                .padding()
            }
            .edgesIgnoringSafeArea(.all)
            .onReceive(timer) { _ in
                teams = scene.level?.teams ?? []
            }
        }
    }
    
}

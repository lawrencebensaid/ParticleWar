//
//  ParticleWarApp.swift
//  ParticleWar
//
//  Created by Lawrence Bensaid on 16/10/22.
//

import SwiftUI
import SpriteKit

@main
struct ParticleWarApp: App {
    
    @State private var scene: GameScene?
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @ObservedObject private var game = Game()
    
    @AppStorage("enabled_preference") private var hideOverlay = false
    
    @State private var teams: [Team] = []
    @State private var fpsLabel = 0
    
    var body: some Scene {
        WindowGroup {
            if let scene = scene {
                ZStack {
                    SpriteView(scene: scene)
                        .environmentObject(game)
                        .edgesIgnoringSafeArea(.all)
                    if !hideOverlay {
                        VStack {
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
                            Spacer()
                            Text("\(fpsLabel) FPS")
                                .bold()
                                .foregroundColor(.yellow)
                        }
                    }
                }
                .foregroundColor(.white)
                .frame(minWidth: 400, minHeight: 250)
                .onReceive(timer) { _ in
                    withAnimation {
                        fpsLabel = Int(game.fps)
                        teams = (scene.level?.teams ?? []).sorted(by: { $0.score > $1.score })
                    }
                }
            } else {
                Text("Loading...")
                    .frame(minWidth: 250, minHeight: 200)
                    .task {
                        scene = GameScene.initialize(game)
                    }
            }
        }
    }
}

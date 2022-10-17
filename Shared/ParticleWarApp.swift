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
    
    @Environment(\.scenePhase) var scenePhase
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @ObservedObject private var game = Game()
    
    @AppStorage("enabled_preference") private var hideOverlay = false
    
    @State private var teams: [Team] = []
    @State private var engineLabel = "Speed: #.#; Sim speed: #.##"
    
    var body: some Scene {
        WindowGroup {
            switch game.state {
            case .inGame:
                if let scene = game.scene {
                    gameView(scene)
                }
            case .gameOver(let reason):
                GameOverView(reason == .won ? "Victory!" : "You lost :(")
                    .frame(minWidth: 250, minHeight: 200)
                    .environmentObject(game)
            default:
                MenuView()
                    .frame(minWidth: 250, minHeight: 200)
                    .environmentObject(game)
            }
        }
        .onChange(of: scenePhase) {
            if $0 == .active {
                game.pause()
            }
        }
        .commands {
            CommandMenu("Game") {
                if game.state == .inGame {
                    Button(game.isPaused ? "Resume" : "Pause") {
                        game.isPaused ? game.unpause() : game.pause()
                    }
                    .keyboardShortcut(.escape, modifiers: [])
                }
            }
        }
    }
    
    private func gameView(_ scene: GameScene) -> some View {
        ZStack {
            SpriteView(scene: scene)
                .environmentObject(game)
                .edgesIgnoringSafeArea(.all)
            if game.isPaused {
                PausedView()
                    .environmentObject(game)
            } else if !hideOverlay {
                overlayView
            }
        }
        .foregroundColor(.white)
        .frame(minWidth: 400, minHeight: 250)
        .onReceive(timer) { _ in
            withAnimation {
                let speed = Double(game.scene?.speed ?? 0)
                engineLabel = "Speed: \(speed.round(to: 1)); Sim speed: \(game.sim.round(to: 2))"
                teams = (scene.level?.teams ?? []).sorted(by: { $0.score > $1.score })
            }
        }
    }
    
    private var overlayView: some View {
        VStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(teams) { team in
                        Label("\(team.name) \(team.score)", systemImage: "circle.circle.fill")
                            .foregroundColor(Color(team.color))
                    }
                }
                .padding()
                .help("Leaderboard")
                Spacer()
                Text("\(Int(game.time))")
                    .font(.system(size: 24, weight: .bold))
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    let client = game.scene?.level?.player
                    Label("\(client?.ownTerritories.count ?? 0)", systemImage: "circle.fill")
                        .help("Owned territories")
                    Label("\(client?.armyCount ?? 0)/\(client?.capacity ?? 0)", systemImage: "diamond")
                        .help("Population capacity")
                }
                .padding(.top, 16)
                .padding([.top, .trailing], 8)
            }
            Spacer()
            Text(engineLabel)
                .bold()
                .foregroundColor(.yellow)
        }
    }
}

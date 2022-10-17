//
//  GameOverView.swift
//  ParticleWar iOS
//
//  Created by Lawrence Bensaid on 10/17/22.
//

import SwiftUI

struct GameOverView: View {
    
    @EnvironmentObject private var game: Game
    
    @State private var color: Color
    @State private var colors: [Color] = []
    
    private let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    private let label: String
    
    init(_ label: String = "GAME OVER") {
        self.label = label
        var colors: [Color]!
        if #available(iOS 15.0, *) {
            colors = [.red, .orange, .yellow, .green, .mint, .teal, .cyan, .blue, .indigo, .purple, .pink, .brown].shuffled()
        } else {
            colors = [.red, .orange, .yellow, .green, .blue, .purple, .pink].shuffled()
        }
        self.colors = colors
        _color = State(initialValue: colors.randomElement() ?? .white)
    }
    
    var body: some View {
        ZStack {
            color
                .ignoresSafeArea()
            VStack(spacing: 8) {
                Text(label)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.bottom, 32)
                Button {
                    game.reset()
                } label: {
                    Text("Main menu")
                        .padding(.vertical, 16)
                        .padding(.horizontal, 28)
                }
                .buttonStyle(.plain)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .frame(height: 48)
                .background(Color.blue.blur(radius: 4))
                .cornerRadius(8)
            }
        }
        .onReceive(timer) { _ in
            if let color = colors.first {
                colors.removeFirst()
                colors.append(color)
                withAnimation(.linear(duration: 1)) {
                    self.color = color
                }
            }
        }
    }
    
}

struct GameOverView_Previews: PreviewProvider {
    static var previews: some View {
        GameOverView()
    }
}

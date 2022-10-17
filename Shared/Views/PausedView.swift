//
//  PausedView.swift
//  ParticleWar iOS
//
//  Created by Lawrence Bensaid on 10/17/22.
//

import SwiftUI

struct PausedView: View {
    
    @EnvironmentObject private var game: Game
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8).blur(radius: 4)
            VStack {
                Text("Paused")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                Button {
                    game.reset()
                } label: {
                    Text("Exit")
                        .padding(.vertical, 16)
                        .padding(.horizontal, 28)
                }
                .buttonStyle(.plain)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .frame(height: 48)
                .background(Color.blue.blur(radius: 4))
                .cornerRadius(8)
                Button {
                    game.unpause()
                } label: {
                    Text("Resume")
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
        .ignoresSafeArea(.all)
    }
    
}

struct PausedView_Previews: PreviewProvider {
    static var previews: some View {
        PausedView()
    }
}

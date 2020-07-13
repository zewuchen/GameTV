//
//  ContentView.swift
//  teste
//
//  Created by Fabrício Guilhermo on 10/07/20.
//  Copyright © 2020 Fabrício Guilhermo. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    var soundManager = SoundManager()

    var body: some View {
        VStack(spacing: 20) {
            Button(action: {
                self.soundManager.play(sound: .playerEaten)
            }) {
                Text("Player Eaten")
            }
            Button(action: {
                self.soundManager.play(sound: .wallCollision)
            }) {
                Text("Wall Collision")
            }
            Button(action: {
                self.soundManager.play(sound: .playerCollision)
            }) {
                Text("Player collision")
            }
        }
        .onAppear(perform: {
            self.soundManager.play(sound: .backgroundSong)
        })
    }
}

//
//  ContentView.swift
//  teste
//
//  Created by Fabrício Guilhermo on 10/07/20.
//  Copyright © 2020 Fabrício Guilhermo. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    private var soundManager = SoundManager()
    private var backgroundSong = SoundManager()
    @State private var musicOn: Bool = true

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
                Text("Wall collision")
            }
            Button(action: {
                self.soundManager.play(sound: .playerCollision)
            }) {
                Text("Player collision")
            }
            Button(action: {
                self.backgroundSong.stopSound()
                self.musicOn.toggle()
            }) {
                musicOn ? Text("Stop music") : Text("Play music")
            }
        }
        .onAppear(perform: {
            self.backgroundSong.play(sound: .backgroundSong)
        })
    }
}

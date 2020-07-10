//
//  ContentView.swift
//  teste
//
//  Created by Fabrício Guilhermo on 10/07/20.
//  Copyright © 2020 Fabrício Guilhermo. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    var soundMan = SoundManager()

    var body: some View {
        VStack(spacing: 20) {
            Button(action: {
                self.soundMan.play(sound: .playerEaten)
            }) {
                Text("Player Eaten")
            }
            Button(action: {
                self.soundMan.play(sound: .wallCollision)
            }) {
                Text("Wall Collision")
            }
            Button(action: {
                self.soundMan.play(sound: .playerCollision)
            }) {
                Text("Player collision")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

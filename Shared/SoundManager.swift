//
//  SoundManager.swift
//  tvAPP
//
//  Created by Fabrício Guilhermo on 10/07/20.
//  Copyright © 2020 Zewu Chen. All rights reserved.
//

import AVFoundation

public enum Sound {
    case playerEaten
    case playerCollision
    case wallCollision
}

final class SoundManager {

    private var player: AVAudioPlayer?

    func play(sound: Sound) {

        var soundURL: URL?

        switch sound {
        case .playerEaten:
            soundURL = Bundle.main.url(forResource: "jogador_pego", withExtension: "mp3")
        case .playerCollision:
            soundURL = Bundle.main.url(forResource: "colisao_jogadores", withExtension: "mp3")
        case .wallCollision:
            soundURL = Bundle.main.url(forResource: "colisao_parede", withExtension: "mp3")
        }

        do {
            try AVAudioSession.sharedInstance().setMode(.default)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            guard let soundURL = soundURL else { return }
            try player = AVAudioPlayer(contentsOf: soundURL)
        } catch {
            print(error.localizedDescription)
        }

        player?.play()
    }
}

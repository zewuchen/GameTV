//
//  ScreenGameViewController.swift
//  tvAPP
//
//  Created by Felipe Petersen on 07/07/20.
//  Copyright © 2020 Zewu Chen. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import MultipeerConnectivity

class ScreenGameViewController: UIViewController {

    @IBOutlet weak var gameView: SKView!
    @IBOutlet var rightScoreView: ScoreController!
    @IBOutlet weak var leftScoreView: ScoreController!
    @IBOutlet weak var counterLabel: UILabel!
    
    var players = [Player]()
    var totalTime = 20
    var map1 = DesignSystemMap1()
    override func viewDidLoad() {
        super.viewDidLoad()
        initScene()
        timerController()
//        timer.fire()
        initViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var rightPlayers = [Player]()
        var leftPlayers = [Player]()
        for player in players {
            if player.menuPosition.0 == 0 {
                leftPlayers.append(player)
            } else {
                rightPlayers.append(player)
            }
        }
        rightScoreView.updateBasedOnPlayers(players: rightPlayers)
        leftScoreView.updateBasedOnPlayers(players: leftPlayers)
    }

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            if(press.type == UIPress.PressType.playPause) {
                let response: String = "PAUSE"
                if let responseData = response.data(using: .utf8) {
                    MultipeerController.shared().sendToAllPeers(responseData, reliably: false)
                }
               // TODO: Fazer iniciar a tela de pause aqui
            }
        }
    }

    func initViews() {
        rightScoreView.scorePosition = .right
        leftScoreView.scorePosition = .left
    }
    
    func initScene() {
        setRandomPlayerAsPegador()
        initPositions()
        if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
            scene.scaleMode = .fill
            scene.gameDelegate = self
            scene.players = self.players
            gameView.backgroundColor = .blue
            gameView.presentScene(scene)
        }
        
        gameView.ignoresSiblingOrder = true
        
        gameView.showsFPS = true
        gameView.showsNodeCount = true
        
        let response: String = "START"
        if let responseData = response.data(using: .utf8) {
            MultipeerController.shared().sendToAllPeers(responseData, reliably: false)
        }
    }
    
    func initPositions() {
        for player in players {
            let pos = map1.getRandomPosition()
            player.instantCol = pos.0
            player.instantRow = pos.1
        }
        map1.resetPos()
    }
    
    func setRandomPlayerAsPegador() {
        guard let randomPlayer = self.players.randomElement() else { fatalError() }
        randomPlayer.isPegador = true
        for player in players {
            if player.id != randomPlayer.id {
                player.isPegador = false
            }
        }
    }
    
    func timeString(time:TimeInterval) -> String {
//        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
    func timerController() {

        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            print("Timer fired!")
            if self.totalTime <  1 {
                timer.invalidate()
                for player in self.players {
                    if !player.isPegador {
                        self.setPointToPlayer(player: player)
                    }
                }
                self.timerRestart()
            }
            self.totalTime -= 1
            self.counterLabel.text = self.timeString(time: TimeInterval(self.totalTime))
        }
    }
    
    func timerRestart() {
        self.initScene()
        self.totalTime = 20
        self.timerController()
    }
    
    func setPointToPlayer(player: Player) {
        for p in players {
            if p.id == player.id {
                player.score += 1
            }
        }
        var rightPlayers = [Player]()
        var leftPlayers = [Player]()
        for p in players {
            if p.menuPosition.0 == 0 {
                leftPlayers.append(player)
            } else {
                rightPlayers.append(player)
            }
        }
        rightScoreView.updatePoints(players: rightPlayers)
        leftScoreView.updatePoints(players: leftPlayers)
    }
}

extension ScreenGameViewController: GameSceneDelegate {
    func endGame(winnerPlayer: Player) {
        setPointToPlayer(player: winnerPlayer)
        self.initScene()
        self.totalTime = 20
    }
}

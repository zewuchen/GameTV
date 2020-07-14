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

    override func viewDidLoad() {
        super.viewDidLoad()
        initScene()
        timerController()
//        timer.fire()
        mockPlayer()
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

    func initViews() {
        rightScoreView.scorePosition = .right
        leftScoreView.scorePosition = .left
    }
    
    func initScene() {
        if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .fill
            scene.gameDelegate = self
//             scene.players
            gameView.backgroundColor = .blue
            // Present the scene
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

    func mockPlayer() {
        let player0 = Player(id: "0", name: "0", colorPlayer: .blue)
        player0.menuPosition = (0,0)
        player0.selectionState = .selected
        player0.score = 2
        self.players.append(player0)
        
        let player1 = Player(id: "1", name: "1", colorPlayer: .blue)
        player1.menuPosition = (1,0)
        player1.selectionState = .selected
        player1.score = 1
        self.players.append(player1)

        let player2 = Player(id: "2", name: "2", colorPlayer: .blue)
        player2.menuPosition = (1,2)
        player2.selectionState = .selected
        player2.score = 0
        self.players.append(player2)
        
        let player3 = Player(id: "3", name: "3", colorPlayer: .blue)
        player3.menuPosition = (0,2)
        player3.selectionState = .selected
//        self.players.append(player3)
        setRandomPlayerAsPegador()
    }
    
    func setRandomPlayerAsPegador() {
        guard let randomPlayer = self.players.randomElement() else { fatalError() }
        randomPlayer.isPegador = true
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
}

extension ScreenGameViewController: GameSceneDelegate {
    func endGame(winnerPlayer: Player) {
        timerRestart()
    }
}

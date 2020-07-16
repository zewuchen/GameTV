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

enum ScreenGameState {
    case playing
    case paused
    case end
}

class ScreenGameViewController: UIViewController {

    @IBOutlet weak var gameView: SKView!
    @IBOutlet var rightScoreView: ScoreController!
    @IBOutlet weak var leftScoreView: ScoreController!
    @IBOutlet weak var counterLabel: UILabel!
    
    //End Views
    @IBOutlet weak var endMainView: UIView!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var backStartButton: UIButton!
    @IBOutlet weak var winnerView: UIView!
    
    //Pause Views
    @IBOutlet weak var pauseView: UIView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var backStartFromPauseButton: UIButton!
    
    
    var players = [Player]()
    var totalTime = 20
    var map1 = DesignSystemMap1()
    var state: ScreenGameState = .playing
    var timer: Timer?
    
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
            player.lock = false
        }
    }
    
    func timeString(time:TimeInterval) -> String {
//        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
    func timerController() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
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
            if player.score == 4 {
                setEndState(winnerPlayer: player)
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
    
    func hiddeAll() {
        self.counterLabel.isHidden = true
        self.gameView.isHidden = true
        self.endMainView.isHidden = true
        self.pauseView.isHidden = true
    }
    
    //Estado de fim de jogo
    func setEndState(winnerPlayer: Player) {
        let response: String = "END"
        if let responseData = response.data(using: .utf8) {
               MultipeerController.shared().sendToAllPeers(responseData, reliably: false)
        }
        self.hiddeAll()
        timer?.invalidate()
        self.state = .end
        self.endMainView.isHidden = false
        self.restartButton.becomeFirstResponder()
        self.setNeedsFocusUpdate()
        self.winnerView.backgroundColor = winnerPlayer.colorPlayer.color
    }
    
    @IBAction func restartGameTap(_ sender: Any) {
        let response: String = "RESTART"
        if let responseData = response.data(using: .utf8) {
               MultipeerController.shared().sendToAllPeers(responseData, reliably: false)
        }
        timer?.invalidate()
    }
    
    @IBAction func backToStartTapped(_ sender: Any) {
        let response: String = "NEWGAME"
        if let responseData = response.data(using: .utf8) {
               MultipeerController.shared().sendToAllPeers(responseData, reliably: false)
        }
    }
    
    //Estado de pause
    func setPauseState() {
        self.hiddeAll()
        timer?.invalidate()
        self.pauseView.isHidden = false
        self.counterLabel.isHidden = false
        self.continueButton.becomeFirstResponder()
        self.setNeedsFocusUpdate()
    }
    
    func setContinueGame() {
        self.hiddeAll()
        timer?.fire()
        self.gameView.isHidden = false
        self.counterLabel.isHidden = false
    }
    
    @IBAction func continueGameTapped(_ sender: Any) {
        
    }
    
}

extension ScreenGameViewController: GameSceneDelegate {
    func endGame(winnerPlayer: Player) {
        setPointToPlayer(player: winnerPlayer)
        self.initScene()
        self.totalTime = 20
    }
}

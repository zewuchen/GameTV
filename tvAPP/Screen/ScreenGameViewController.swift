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
    case startRound
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
    
    //Round Views
    @IBOutlet weak var roundView: UIView!
    @IBOutlet weak var roundLabel: UILabel!
    @IBOutlet weak var playersStackView: UIStackView!
    @IBOutlet weak var pegadorView: UIView!
    
    var players = [Player]()
    var roundPlayers = [Player]()
    var totalTime = 60
    var map1 = DesignSystemMap1()
    var state: ScreenGameState = .playing
    var timer: Timer?
    var roundCounter = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initScene()
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
        self.setRoundState()
        if let scene = GameScene(fileNamed: "GameScene") {
            scene.scaleMode = .fill
            scene.gameDelegate = self
            gameView.backgroundColor = DesignSystem.Colors.gray
            roundPlayers = players
            scene.players = self.roundPlayers
            gameView.presentScene(scene)
        }
        
        gameView.ignoresSiblingOrder = true

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
            if self.totalTime <  1 {
                timer.invalidate()
                for player in self.roundPlayers {
                    if !player.isPegador {
                        self.setPointToPlayer(player: player)
                    }
                }
                if self.state != .end {
                    self.timerRestart()
                }
            }
            self.totalTime -= 1
            self.counterLabel.text = self.timeString(time: TimeInterval(self.totalTime))
        }
    }
    
    func timerRestart() {
        self.initScene()
        self.totalTime = 60
    }
    
    func setPointToPlayer(player: Player) {
        for p in players {
            if p.id == player.id {
                player.score += 1
            }
            if player.score == 4 {
                setEndState(winnerPlayer: player)
                self.state = .end
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
        self.roundView.isHidden = true
    }
    
    //Estado de começo de round
    func lockAllPlayers() {
        for player in players {
            player.lock = true
        }
    }

    func unlockAllPlayers() {
        for player in players {
            player.lock = false
        }
    }
    
    func setRoundState() {
        self.counterLabel.text = "01:00"
        self.roundView.isHidden = false
        self.roundLabel.text = "Round \(roundCounter)"
        roundCounter += 1
        self.timer?.invalidate()
        self.lockAllPlayers()
        for subview in playersStackView.subviews {
            if subview.tag == 1 {
                subview.removeFromSuperview()
            }
        }
        for player in players {
            if player.isPegador {
                self.pegadorView.backgroundColor = player.colorPlayer.color
            } else {
                let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                view.backgroundColor = player.colorPlayer.color
                view.addConstraint(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50))
                view.addConstraint(NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50))
                view.tag = 1
                self.playersStackView.addArrangedSubview(view)
            }
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (timer) in
            self.timerController()
            self.roundView.isHidden = true
            self.unlockAllPlayers()
        }
    }
    
    //Estado de fim de jogo
    func setEndState(winnerPlayer: Player) {
        let response: String = "END"
        if let responseData = response.data(using: .utf8) {
               MultipeerController.shared().sendToAllPeers(responseData, reliably: false)
        }
        self.hiddeAll()
        self.endMainView.isHidden = false
        self.restartButton.becomeFirstResponder()
        self.setNeedsFocusUpdate()
        self.winnerView.backgroundColor = winnerPlayer.colorPlayer.color
        self.timer?.invalidate()
    }
    
    @IBAction func restartGameTap(_ sender: Any) {
        let response: String = "RESTART"
        if let responseData = response.data(using: .utf8) {
               MultipeerController.shared().sendToAllPeers(responseData, reliably: false)
        }
        restartGame()
    }
    
    func restartGame() {
        self.state = .playing
        self.hiddeAll()
        self.gameView.isHidden = false
        self.counterLabel.isHidden = false
        timer?.invalidate()
        self.initPositions()
        self.timerRestart()
        self.resetPoints()
        self.setRandomPlayerAsPegador()
        self.roundCounter = 1
        self.roundLabel.text = "Round \(roundCounter)"
        self.counterLabel.text = "01:00"
    }
    
    func resetPoints() {
        for p in players {
            p.score = 0
            p.lock = false
        }
        var rightPlayers = [Player]()
        var leftPlayers = [Player]()
        for p in players {
            if p.menuPosition.0 == 0 {
                leftPlayers.append(p)
            } else {
                rightPlayers.append(p)
            }
        }
        rightScoreView.resetPoint(players: rightPlayers)
        leftScoreView.resetPoint(players: leftPlayers)
    }
    
    @IBAction func backToStartTapped(_ sender: Any) {
        let response: String = "NEWGAME"
        if let responseData = response.data(using: .utf8) {
               MultipeerController.shared().sendToAllPeers(responseData, reliably: false)
        }

        if let vc = HomeViewController() as? HomeViewController {
            self.timer?.invalidate()
            vc.players = self.players
            vc.alreadyStartFirstTime = true
            vc.resetPlayers()
            UIApplication.shared.windows.first?.rootViewController = vc
            UIApplication.shared.windows.first?.makeKeyAndVisible()
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    //Estado de pause
    func setPauseState() {
        self.hiddeAll()
        self.state = .paused
        timer?.invalidate()
        self.pauseView.isHidden = false
        self.counterLabel.isHidden = false
        self.continueButton.becomeFirstResponder()
        self.setNeedsFocusUpdate()
    }
    
    func setContinueGame() {
        let response: String = "CONTINUE"
        if let responseData = response.data(using: .utf8) {
               MultipeerController.shared().sendToAllPeers(responseData, reliably: false)
        }
        self.hiddeAll()
        self.timerController()
        self.gameView.isHidden = false
        self.counterLabel.isHidden = false
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            if(press.type == UIPress.PressType.playPause) {
                let response: String = "PAUSE"
                if let responseData = response.data(using: .utf8) {
                    MultipeerController.shared().sendToAllPeers(responseData, reliably: false)
                }
               setPauseState()
            }
        }
    }

    
    @IBAction func continueGameTapped(_ sender: Any) {
        setContinueGame()
    }
    
}

extension ScreenGameViewController: GameSceneDelegate {
    func removePlayer(player: Player) {
        for aPlayer in players {
            aPlayer.lock = false
        }
        self.roundPlayers.removeAll { (player) -> Bool in
            return player.id == player.id
        }
        self.totalTime += 10
    }
    
    func endGame(winnerPlayer: Player) {
        self.totalTime = 60
        self.initScene()
        setPointToPlayer(player: winnerPlayer)
    }
}

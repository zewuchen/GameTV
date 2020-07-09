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
    
    var players = [Player]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mockPlayer()
        initViews()
        if let scene = SKScene(fileNamed: "GameScene") {
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .fill
            gameView.backgroundColor = .blue
            // Present the scene
            gameView.presentScene(scene)
        }
        
        gameView.ignoresSiblingOrder = true
        
        gameView.showsFPS = true
        gameView.showsNodeCount = true
        // Do any additional setup after loading the view.
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

    func mockPlayer() {
        let player0 = Player(id: "0", name: "0", colorPlayer: .blue)
        player0.menuPosition = (0,0)
        player0.selectionState = .selected
        self.players.append(player0)
        
        let player1 = Player(id: "1", name: "1", colorPlayer: .blue)
        player1.menuPosition = (1,0)
        player1.selectionState = .selected
        self.players.append(player1)

        let player2 = Player(id: "2", name: "2", colorPlayer: .blue)
        player2.menuPosition = (1,2)
        player2.selectionState = .selected
        self.players.append(player2)
        
        let player3 = Player(id: "3", name: "3", colorPlayer: .blue)
        player3.menuPosition = (0,2)
        player3.selectionState = .selected
//        self.players.append(player3)
    }
}

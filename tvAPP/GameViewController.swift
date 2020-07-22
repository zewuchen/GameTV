//
//  GameViewController.swift
//  tvAPP
//
//  Created by Zewu Chen on 02/07/20.
//  Copyright © 2020 Zewu Chen. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import MultipeerConnectivity

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MultipeerController.shared().delegate = self
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
}

extension GameViewController: MultipeerHandler {
    func peerReceivedInvitation(_ id: MCPeerID) -> Bool {
        return true
    }
    
    func receivedData(_ data: Data, from peerID: MCPeerID) {
        guard let texto = String(bytes: data, encoding: .utf8) else { return }
        let move = Movement(decode: texto)
    }
}

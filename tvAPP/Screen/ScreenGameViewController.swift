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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

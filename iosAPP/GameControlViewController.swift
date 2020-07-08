//
//  GameControlViewController.swift
//  iosAPP
//
//  Created by Zewu Chen on 08/07/20.
//  Copyright © 2020 Zewu Chen. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class GameControlViewController: UIViewController {

    var host: MCPeerID?
    var color: UIColor?
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTrack: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)

        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)

        MultipeerController.shared().delegate = self
    }

    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        var movement: String = "0"

        if gesture.direction == .up {
            movement = "1"
        }
        else if gesture.direction == .down {
            movement = "2"
        }
        else if gesture.direction == .left {
            movement = "3"
        }
        else if gesture.direction == .right {
            movement = "4"
        }

        if let movementData = movement.data(using: .utf8), let host = host {
            MultipeerController.shared().sendToPeers(movementData, reliably: false, peers: [host])
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        if let colorView = colorView, let color = color {
            DispatchQueue.main.async {
                colorView.backgroundColor = color
            }
        }
    }
}

extension GameControlViewController : MultipeerHandler {
    func peerDiscovered(_ id: MCPeerID) -> Bool {
        host = id
        return true
    }

    func peerLost(_ id: MCPeerID) { }
    
    func receivedData(_ data: Data, from peerID: MCPeerID) { }
}
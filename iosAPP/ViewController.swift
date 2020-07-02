//
//  ViewController.swift
//  iOSMultiPeer
//
//  Created by Zewu Chen on 30/06/20.
//  Copyright © 2020 Zewu Chen. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController {

    var host: MCPeerID?

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
        var movement: String = "invalid"

        if gesture.direction == .right {
            movement = "right"
        }
        else if gesture.direction == .left {
            movement = "left"
        }
        else if gesture.direction == .up {
            movement = "up"
        }
        else if gesture.direction == .down {
            movement = "down"
        }

        if let movementData = movement.data(using: .utf8) {
            MultipeerController.shared().sendToAllPeers(movementData, reliably: false)
        }
    }

}

extension ViewController: MultipeerHandler {
    func peerDiscovered(_ id: MCPeerID) -> Bool {
        host = id
        return true
    }

    func peerLost(_ id: MCPeerID) {

    }


}


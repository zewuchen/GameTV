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

    @IBOutlet weak var selectionView: SelectionController!
    
    var host: MCPeerID?
    var instantPos = (0,0)

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

}

extension ViewController: MultipeerHandler {

    // Quando encontra o host do jogo (AppleTV)
    func peerDiscovered(_ id: MCPeerID) -> Bool {
        host = id
        return true
    }
        
    func peerLost(_ id: MCPeerID) { }

    func receivedData(_ data: Data, from peerID: MCPeerID) {
        guard let texto = String(bytes: data, encoding: .utf8) else { return }
        let move = Movement(decode: texto)

        switch move.type {
        case .up:
            animatedSelections(swipe: .up)
        case .down:
            animatedSelections(swipe: .down)
        case .left:
            animatedSelections(swipe: .left)
        case .right:
            animatedSelections(swipe: .right)
        case .invalid:
            break
        }
    }

    func animatedSelections(swipe: MovementType) {
        DispatchQueue.main.async {
            let finalPos = self.selectionView.changePos(instantPos: self.instantPos, swipe: swipe)
            self.instantPos = finalPos
        }
    }

}

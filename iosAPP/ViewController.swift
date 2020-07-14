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
    @IBOutlet weak var btnEscolher: UIButton!
    @IBOutlet weak var lblTrack: UILabel!
    
    var host: MCPeerID?
    var instantPos = (0,0)
    var enableConnectivity = true
    var sendData = true

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

    override func viewWillAppear(_ animated: Bool) {
        enableConnectivity = true
        sendData = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        enableConnectivity = false
        sendData = false
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

        if let movementData = movement.data(using: .utf8), let host = host, sendData {
            MultipeerController.shared().sendToPeers(movementData, reliably: true, peers: [host])
        }
    }

    @IBAction func btnEscolher(_ sender: Any) {
        let choice: String = "LOCKCOLOR"

        if let choiceData = choice.data(using: .utf8), let host = host, sendData {
            MultipeerController.shared().sendToPeers(choiceData, reliably: true, peers: [host])
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
        if enableConnectivity {
            guard let texto = String(bytes: data, encoding: .utf8) else { return }
            let move = Movement(decode: texto)
            let command = CommandSystem(decode: texto)

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
                commandGame(command: command)
            }
        }
    }

    func animatedSelections(swipe: MovementType) {
        DispatchQueue.main.async {
            let finalPos = self.selectionView.changePos(instantPos: self.instantPos, swipe: swipe)
            self.instantPos = finalPos
        }
    }

    func commandGame(command: CommandSystem) {
        switch command.command {
        case .start:
            enableConnectivity = false
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let vc = storyboard.instantiateViewController(identifier: "gameControlViewController") as? GameControlViewController {
                    vc.host = self.host
                    vc.color = self.selectionView.colors[self.instantPos.0][self.instantPos.1].color
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
            }
        case .pause:
            break
        case .continue:
            break
        case .restart:
            break
        case .end:
            break
        case .newGame:
            break
        case .lockColor:
            break
        case .confirmedColor:
            lockChoice(track: "Cor escolhida")
        case .cannotConfirmeColor:
            invalidChoice(track: "Cor já selecionada")
        case .invalid:
            break
        }
    }

    func lockChoice(track: String) {
        sendData = false
        DispatchQueue.main.async {
            self.btnEscolher.isEnabled = false
            self.btnEscolher.isHidden = true
            self.lblTrack.text = track
        }
    }

    func invalidChoice(track: String) {
        DispatchQueue.main.async {
            self.lblTrack.text = track
        }
    }

}

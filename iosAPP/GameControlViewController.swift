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
    var pause: Bool = false
    weak public var delegate: GameDelegate?
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
        
        if let movementData = movement.data(using: .utf8), let host = host, !pause {
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
    
    func receivedData(_ data: Data, from peerID: MCPeerID) {
        guard let texto = String(bytes: data, encoding: .utf8) else { return }
        let command = CommandSystem(decode: texto)
        
        commandGame(command: command)
    }
    
    func commandGame(command: CommandSystem) {
        switch command.command {
        case .start:
            break
        case .pause:
            updateLabel(title: "Jogo pausado", track: "Aguarde a retomada do jogo")
            pause = true
        case .continue:
            updateLabel(title: "Jogo em andamento", track: "Deslize para mover")
            pause = false
        case .restart:
            updateLabel(title: "Jogo em andamento", track: "Deslize para mover")
            pause = false
        case .end:
            updateLabel(title: "Fim de jogo!", track: "Bom jogo, jogue novamente!")
            pause = true
        case .newGame:
            DispatchQueue.main.async {
                self.delegate?.newGame()
                self.dismiss(animated: true, completion: nil)
            }
        case .lockColor:
            break
        case .confirmedColor:
            break
        case .cannotConfirmeColor:
            break
        case .invalid:
            break
        }
    }
    
    func updateLabel(title: String, track: String) {
        DispatchQueue.main.async {
            self.lblTitle.text = title
            self.lblTrack.text = track
        }
    }
}

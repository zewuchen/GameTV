//
//  HomeViewController.swift
//  tvAPP
//
//  Created by Felipe Petersen on 03/07/20.
//  Copyright © 2020 Zewu Chen. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class HomeViewController: UIViewController {

    @IBOutlet weak var selectionView: SelectionController!
    @IBOutlet weak var playButtonOutlet: UIButton!
    @IBOutlet weak var waitForPlayersLabel: UILabel!
    //    var instantCol = 0
//    var instantRow = 0
    var startPos = (0,0)
    var players = [Player]()
    var countColors: (Int, Int)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MultipeerController.shared().delegate = self
        self.playButtonOutlet.isEnabled = false
        self.createGestures()
//        initControl()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.initControl()
        self.countColors = self.selectionView.getLimitsOfColors()
    }
    
    func createGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        self.view.addGestureRecognizer(tap)
    }
    
    func initControl() {
        let controlPlayer = Player(id: "RemoteControl", name: "RemoteControl", colorPlayer: selectionView.getColor(instantPos: startPos))
        self.players.append(controlPlayer)
        self.selectionView.updateBasedOnPlayersPosition(players: self.players)
    }
     
    //MARK:- Handle gestures remoteControl
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            print("Swipe Right")
            if players[0].menuPosition.0 + 1 < countColors?.0 ?? 0 {
                players[0].menuPosition.0 += 1
            }
//            let finalPos = self.selectionView.changePos(instantPos: startPos, swipe: .right)
//            self.startPos = finalPos
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            print("Swipe Left")
            if players[0].menuPosition.0 - 1 >= 0 {
                players[0].menuPosition.0 -= 1
            }
//            let finalPos = self.selectionView.changePos(instantPos: startPos, swipe: .left)
//            self.startPos = finalPos
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.up {
            print("Swipe Up")
            if players[0].menuPosition.1 - 1 >= 0 {
                players[0].menuPosition.1 -= 1
            } else {
                players[0].menuPosition.1 = (countColors?.1 ?? 0) - 1
            }
//            let finalPos = self.selectionView.changePos(instantPos: startPos, swipe: .up)
//            self.startPos = finalPos
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.down {
            print("Down")
            if players[0].menuPosition.1 + 1 < countColors?.1 ?? 0 {
                players[0].menuPosition.1 += 1
            } else {
                players[0].menuPosition.1 = 0
            }

//            let finalPos = self.selectionView.changePos(instantPos: startPos, swipe: .down)
//            self.startPos = finalPos
        }
        self.selectionView.updateBasedOnPlayersPosition(players: self.players)
    }
    
    @objc func didTap() {
//        let worked = self.selectionView.selectItem(instantPos: startPos)
        if lockColorRemote(player: self.players[0]) {
            self.players[0].selectionState = .selected
                    self.view.gestureRecognizers?.removeAll()
                    playButtonOutlet.isEnabled = true
                    playButtonOutlet.becomeFirstResponder()
                    self.setNeedsFocusUpdate()
                    self.playButtonOutlet.setTitleColor(.black, for: .normal)
            //        self.playButtonOutlet.tintColor = .white
                    self.selectionView.updateBasedOnPlayersPosition(players: self.players)
            //        self.view.setNeedsDisplay()
            //        self.reloadInputViews()
        }
    }
    
    @IBAction func didTapPlay(_ sender: Any) {
        if checkEveryoneReady() {
            let gameVC = ScreenGameViewController()
            self.show(gameVC, sender: self)
        } else {
            self.waitForPlayersLabel.alpha = 1
            UIView.animate(withDuration: 3) {
                self.waitForPlayersLabel.alpha = 0
            }
        }
        print("Play")
    }
    
    func checkEveryoneReady() -> Bool {
        var ready = true
        for player in players {
            if player.selectionState != .selected {
                ready = false
            }
        }
        return ready
    }
}

//MARK:- Multipeer handler
extension HomeViewController: MultipeerHandler {
    
    func peerReceivedInvitation(_ id: MCPeerID) -> Bool {
        let phonePlayer = Player(id: id.description, name: id.displayName, colorPlayer: selectionView.getColor(instantPos: startPos))
        self.players.append(phonePlayer)
        print("Connected")
        self.selectionView.updateBasedOnPlayersPosition(players: self.players)
        return MultipeerController.shared().connectedPeers.count < 5
    }
    
    func receivedData(_ data: Data, from peerID: MCPeerID) {
        guard let texto = String(bytes: data, encoding: .utf8) else { return }
        let command = CommandSystem(decode: texto)
        let move = Movement(decode: texto)
        var playerAux: Player?
        
        for index in 0..<players.count {
            if players[index].id == peerID.description {
                playerAux = players[index]
            }
        }

        guard var player = playerAux else { return }
        print(move.type)
        switch move.type {
        case .down:
            if player.menuPosition.1 + 1 < countColors?.1 ?? 0 {
                player.menuPosition.1 += 1
            } else {
                player.menuPosition.1 = 0
            }
        case .up:
            if player.menuPosition.1 - 1 >= 0 {
                player.menuPosition.1 -= 1
            } else {
                player.menuPosition.1 = (countColors?.1 ?? 0) - 1
            }
        case .left:
            if player.menuPosition.0 - 1 >= 0 {
                player.menuPosition.0 -= 1
            }
        case .right:
            if player.menuPosition.0 + 1 < countColors?.0 ?? 0 {
                player.menuPosition.0 += 1
            }
        case .invalid:
            commandGame(command: command, peer: peerID)
        }
        MultipeerController.shared().sendToPeers(data, reliably: false, peers: [peerID])
        DispatchQueue.main.async {
            self.selectionView.updateBasedOnPlayersPosition(players: self.players)
        }
    }
    
    func peerLeft(_ id: MCPeerID) {
        let player = players.first { (player) -> Bool in
            return player.id == id.description
        }
        
        let seconds = 5.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.players.removeAll { (removingPlayer) -> Bool in
                player?.id == removingPlayer.id
            }
            self.selectionView.updateBasedOnPlayersPosition(players: self.players)
        }
    }

    func commandGame(command: CommandSystem, peer: MCPeerID) {
        switch command.command {
        case .start:
            break
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
            lockColor(peer: peer)
        case .confirmedColor:
            break
        case .cannotConfirmeColor:
            break
        case .invalid:
            break
        }
    }

    func lockColor(peer: MCPeerID) {
        let response: String

        let player = players.first { (player) -> Bool in
            return player.id == peer.description
        }

        if let player = player, player.selectionState != .selected {
            let filteredPlayers = self.players.filter({ $0.selectionState == .selected && $0.menuPosition == player.menuPosition })
            if filteredPlayers.count > 0 {
                response = "CANNOTCOLOR"
            } else {
                response = "CONFIRMEDCOLOR"
                player.selectionState = .selected
            }
            if let responseData = response.data(using: .utf8) {
                MultipeerController.shared().sendToPeers(responseData, reliably: true, peers: [peer])
            }
        }
    }

    func lockColorRemote(player: Player) -> Bool {
        let filteredPlayers = self.players.filter({ $0.selectionState == .selected && $0.menuPosition == player.menuPosition })
        if filteredPlayers.count > 0 {
            return false
        } else {
            player.selectionState = .selected
        }

        return true
    }
}

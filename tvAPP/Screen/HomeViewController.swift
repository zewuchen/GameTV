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
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var lblWaiting: UILabel!
    var startPos = (0,0)
    var players = [Player]()
    var countColors: (Int, Int)?
    var enableConnectivity = true
    var alreadyStartFirstTime = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MultipeerController.shared().delegate = self
        self.playButtonOutlet.isEnabled = false
        self.createGestures()
        System.soundManager.play(sound: .backgroundSong)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !self.alreadyStartFirstTime {
            self.initControl()
        } else {
            self.selectionView.updateBasedOnPlayersPosition(players: self.players)
        }
        self.countColors = self.selectionView.getLimitsOfColors()
        loadingAnimation(flag: true)
        enableConnectivity = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        enableConnectivity = false
        loadingAnimation(flag: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.createGestures()
        self.playButtonOutlet.isEnabled = false
        self.setNeedsFocusUpdate()
        for player in players {
            player.menuPosition = (0,0)
            player.selectionState = .preSelected
            player.lock = false
            player.isPegador = false
            player.score = 0
        }
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
            if players[0].menuPosition.0 + 1 < countColors?.0 ?? 0 {
                players[0].menuPosition.0 += 1
            }
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            if players[0].menuPosition.0 - 1 >= 0 {
                players[0].menuPosition.0 -= 1
            }
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.up {
            if players[0].menuPosition.1 - 1 >= 0 {
                players[0].menuPosition.1 -= 1
            } else {
                players[0].menuPosition.1 = (countColors?.1 ?? 0) - 1
            }
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.down {
            if players[0].menuPosition.1 + 1 < countColors?.1 ?? 0 {
                players[0].menuPosition.1 += 1
            } else {
                players[0].menuPosition.1 = 0
            }
        }
        self.selectionView.updateBasedOnPlayersPosition(players: self.players)
    }
    
    @objc func didTap() {
        if lockColorRemote(player: self.players[0]) {
            self.players[0].selectionState = .selected
            self.view.gestureRecognizers?.removeAll()
            DispatchQueue.main.async {
                self.playButtonOutlet.isHidden = false
                self.playButtonOutlet.isEnabled = true
                self.playButtonOutlet.clipsToBounds = true
                self.playButtonOutlet.becomeFirstResponder()
                self.setNeedsFocusUpdate()
            }
            self.selectionView.updateBasedOnPlayersPosition(players: self.players)
        }
    }
    
    @IBAction func didTapPlay(_ sender: Any) {
        self.alreadyStartFirstTime = true
        if checkEveryoneReady(), self.players.count > 1 {
            let gameVC = ScreenGameViewController()
            gameVC.players = self.players
            self.show(gameVC, sender: self)
        } else {
            if self.players.count < 2 {
                self.waitForPlayersLabel.text = "No mínimo 2 jogadores para iniciar..."
            } else {
                self.waitForPlayersLabel.text = "Espere todos os jogadores escolherem"
            }
            self.waitForPlayersLabel.alpha = 1
            UIView.animate(withDuration: 3) {
                self.waitForPlayersLabel.alpha = 0
            }
        }
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

    func loadingAnimation(flag: Bool) {
        if flag {
            DispatchQueue.main.async {
                self.loading.startAnimating()
                self.loading.isHidden = false
                self.lblWaiting.isHidden = false
            }
        } else {
            DispatchQueue.main.async {
                self.loading.stopAnimating()
                self.loading.isHidden = true
                self.lblWaiting.isHidden = true
            }
        }
    }

    func peerReceivedInvitation(_ id: MCPeerID) -> Bool {

        if MultipeerController.shared().connectedPeers.count < 5, enableConnectivity {
            let phonePlayer = Player(id: id.description, name: id.displayName, colorPlayer: selectionView.getColor(instantPos: startPos))
            self.players.append(phonePlayer)
            self.selectionView.updateBasedOnPlayersPosition(players: self.players)

            if players.count <= 5 {
                loadingAnimation(flag: true)
            } else {
                loadingAnimation(flag: false)
            }

            return true
        }

        return false
    }
    
    func receivedData(_ data: Data, from peerID: MCPeerID) {
        if enableConnectivity {
            guard let texto = String(bytes: data, encoding: .utf8) else { return }
            let command = CommandSystem(decode: texto)
            let move = Movement(decode: texto)
            var playerAux: Player?

            for index in 0..<players.count {
                if players[index].id == peerID.description {
                    playerAux = players[index]
                }
            }

            guard let player = playerAux else { return }
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
            MultipeerController.shared().sendToPeers(data, reliably: true, peers: [peerID])
            DispatchQueue.main.async {
                self.selectionView.updateBasedOnPlayersPosition(players: self.players)
            }
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
                player.colorPlayer = selectionView.colors[player.menuPosition.0][player.menuPosition.1]
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
            player.colorPlayer = selectionView.colors[player.menuPosition.0][player.menuPosition.1]
        }

        return true
    }

    func resetPlayers() {
        for player in players {
            player.colorPlayer = .blue
            player.menuPosition = (0,0)
            player.selectionState = .notSelected
        }
    }
}

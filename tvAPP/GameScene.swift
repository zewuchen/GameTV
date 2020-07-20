//
//  GameScene.swift
//  TileTest
//
//  Created by Felipe Petersen on 30/06/20.
//  Copyright © 2020 Felipe Petersen. All rights reserved.
//

import SpriteKit
import GameplayKit
import MultipeerConnectivity

protocol GameSceneDelegate {
    func endGame(winnerPlayer: Player)
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var chao : SKTileMapNode?
    private var squares: [SKShapeNode?] = []
    var players = [Player]()
    
    let tileMapping = TileMapping()
    var player1 = false // Teste
    var gameDelegate: GameSceneDelegate?
    
    override func didMove(to view: SKView) {
        self.chao = self.childNode(withName: "//chao") as? SKTileMapNode
        tileMapping.buildNumericMap(from: chao!)
        self.physicsWorld.contactDelegate = self
        self.initShapes()
        createGestures()
        MultipeerController.shared().delegate = self
    }
    
    func initShapes() {
        for player in players {
            let square = SKShapeNode(rectOf: CGSize(width: 32, height: 32))
            square.fillColor = player.colorPlayer.color
            square.name = player.id
            square.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: square.frame.width - 4, height: square.frame.height - 4))
            square.physicsBody?.isDynamic = true
            square.physicsBody?.affectedByGravity = false
            square.physicsBody?.collisionBitMask = 0
            square.physicsBody!.contactTestBitMask = UInt32.max
            square.physicsBody!.categoryBitMask = UInt32.max
            square.physicsBody?.allowsRotation = false
            square.physicsBody?.friction = 1.0
            if player.isPegador {
                let squarePegador = SKShapeNode(rectOf: CGSize(width: 10, height: 10))
                squarePegador.fillColor = .black
                squarePegador.position = .zero
                square.addChild(squarePegador)
            }
            self.squares.append(square)
        }

        for index in 0..<squares.count {

            if let positionSquare = (chao?.centerOfTile(atColumn: players[index].instantCol, row: players[index].instantRow)), let square = squares[index] {
                
                square.position = positionSquare
                self.chao?.addChild(square)
            }
        }
//        setRandomPlayerAsPegador()
    }
    
    func collisionBetween(square: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(square: square)
        } else if object.name == "bad" {
            destroy(square: square)
        }
    }

    func destroy(square: SKNode) {
        square.removeFromParent()
    }
    
    
    func createGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeLeft.direction = .left
        self.view?.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeRight.direction = .right
        self.view?.addGestureRecognizer(swipeRight)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeUp.direction = .up
        self.view?.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeDown.direction = .down
        self.view?.addGestureRecognizer(swipeDown)
        
    }
    //MARK:- Handle gestures remoteControl
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if !players[0].lock {
        let instantPos = (chao?.centerOfTile(atColumn: players[0].instantCol, row: players[0].instantRow))!
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
             players[0].instantCol = tileMapping.getIndexWallRightRow(instantRow: players[0].instantRow, instantCol: players[0].instantCol) ?? 0
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            players[0].instantCol = tileMapping.getIndexWallLeftRow(instantRow: players[0].instantRow, instantCol: players[0].instantCol) ?? 0
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.up {
            players[0].instantRow = tileMapping.getIndexWallUpColumn(instantRow: players[0].instantRow, instantCol: players[0].instantCol) ?? 0
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.down {
            players[0].instantRow = tileMapping.getIndexWallDownColumn(instantRow: players[0].instantRow, instantCol: players[0].instantCol) ?? 0

        }
        if let destination = (chao?.centerOfTile(atColumn: players[0].instantCol, row: players[0].instantRow)) {
        let action = SKAction.move(to: destination, duration: self.getDuration(pointA: instantPos, pointB: destination, speed: 1000))
        players[0].lock = true
        self.squares.first??.run(action, completion: {
            self.players[0].lock = false
        })
        }
        
        }
    }
    
    func getDuration(pointA:CGPoint,pointB:CGPoint,speed:CGFloat)->TimeInterval {
        let xDist = (pointB.x - pointA.x)
        let yDist = (pointB.y - pointA.y)
        let distance = sqrt((xDist * xDist) + (yDist * yDist));
        let duration : TimeInterval = TimeInterval(distance/speed)
        return duration
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        contact.bodyA.node?.removeAllActions()
        contact.bodyB.node?.removeAllActions()
        var playerA: Player?
        var playerB: Player?
        for player in players {
            if contact.bodyA.node?.name == player.id {
                playerA = player
            }
            if contact.bodyB.node?.name == player.id {
                playerB = player
            }
        }

        guard let gPlayerA = playerA, let gPlayerB = playerB else { fatalError() }

        if gPlayerA.isPegador && !gPlayerB.isPegador {
            gameDelegate?.endGame(winnerPlayer: gPlayerA)
        } else if !gPlayerA.isPegador && gPlayerB.isPegador {
            gameDelegate?.endGame(winnerPlayer: gPlayerB)
        } else if (gPlayerA.isPegador && gPlayerB.isPegador) || (!gPlayerA.isPegador && !gPlayerB.isPegador) {
            gPlayerA.lock = false
            guard let newRow = self.chao?.tileRowIndex(fromPosition: contact.bodyA.node!.position) else { fatalError() }
            guard let newColumn = self.chao?.tileColumnIndex(fromPosition: contact.bodyA.node!.position) else { fatalError() }
            gPlayerA.instantRow = newRow
            gPlayerA.instantCol = newColumn
            
            gPlayerB.lock = false
            guard let newRowB = self.chao?.tileRowIndex(fromPosition: contact.bodyB.node!.position) else { fatalError() }
            guard let newColumnB = self.chao?.tileColumnIndex(fromPosition: contact.bodyB.node!.position) else { fatalError() }
            gPlayerB.instantRow = newRowB
            gPlayerB.instantCol = newColumnB
            
        }

      }
    
    func didEnd(_ contact: SKPhysicsContact) {
    }
}

extension GameScene: MultipeerHandler {
    
    func peerReceivedInvitation(_ id: MCPeerID) -> Bool {
        return true
    }
    
    func receivedData(_ data: Data, from peerID: MCPeerID) {
        guard let texto = String(bytes: data, encoding: .utf8) else { return }
        let move = Movement(decode: texto)
        var playerAux: Player?
        var squareAux: SKShapeNode?
        
        // Encontra qual é o player e a square que vai se mover
        for index in 0..<players.count {
            if players[index].id == peerID.description {
                playerAux = players[index]
            }
            if squares[index]?.name == peerID.description {
                squareAux = squares[index]
            }
        }
        
        guard var player = playerAux else { return }
        guard var square = squareAux else { return }
        
        if !player.lock {
            guard let instantPos = (chao?.centerOfTile(atColumn: player.instantCol, row: player.instantRow)) else { return }
            switch move.type {
            case .right :
                player.instantCol = tileMapping.getIndexWallRightRow(instantRow: player.instantRow, instantCol: player.instantCol) ?? 0
            case .left:
                player.instantCol = tileMapping.getIndexWallLeftRow(instantRow: player.instantRow, instantCol: player.instantCol) ?? 0
            case .up:
                player.instantRow = tileMapping.getIndexWallUpColumn(instantRow: player.instantRow, instantCol: player.instantCol) ?? 0
            case .down: 
                player.instantRow = tileMapping.getIndexWallDownColumn(instantRow: player.instantRow, instantCol: player.instantCol) ?? 0
            default:
                break
            }
            if let destination = (chao?.centerOfTile(atColumn: player.instantCol, row: player.instantRow)) {
                let action = SKAction.move(to: destination, duration: self.getDuration(pointA: instantPos, pointB: destination, speed: 1000))
                player.lock = true
                square.run(action, completion: {
                    player.lock = false
                })
            }
        }
    }
}

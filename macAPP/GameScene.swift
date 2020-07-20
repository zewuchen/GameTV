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

class GameScene: SKScene {
    
    private var chao : SKTileMapNode?
    private var squares: [SKShapeNode?] = []
    var players: [Player] = [
        Player(id: "1", name: "Teste1", colorPlayer: .blue, instantCol: 1, instantRow: 22),
        Player(id: "2", name: "Teste2", colorPlayer: .red, instantCol: 22, instantRow: 22)]
    
    let tileMapping = TileMapping()
    var player1 = false // Teste
    
    override func didMove(to view: SKView) {
        self.chao = self.childNode(withName: "//chao") as? SKTileMapNode
        tileMapping.buildNumericMap(from: chao!)
        self.initShapes()

        MultipeerController.shared().delegate = self
    }
    
    func initShapes() {
        for player in players {
            let square = SKShapeNode(rectOf: CGSize(width: 32, height: 32))
            square.fillColor = player.colorPlayer.color
            square.name = player.id
            self.squares.append(square)
        }

        for index in 0..<squares.count {
            if let positionSquare = (chao?.centerOfTile(atColumn: players[index].instantCol, row: players[index].instantRow)), let square = squares[index] {
                square.position = positionSquare
                self.chao?.addChild(square)
            }
        }
    }
    
    override func keyDown(with event: NSEvent) {
        guard var player = players.first else { return }
        if !player.lock {
            let character = Int16(event.keyCode)
            let instantPos = (chao?.centerOfTile(atColumn: player.instantCol, row: player.instantRow))!
            switch character {
            case 0x7C : //right
                player.instantCol = tileMapping.getIndexWallRightRow(instantRow: player.instantRow, instantCol: player.instantCol) ?? 0
            case 0x7B: //left
                player.instantCol = tileMapping.getIndexWallLeftRow(instantRow: player.instantRow, instantCol: player.instantCol) ?? 0
            case 0x7E: //up
                player.instantRow = tileMapping.getIndexWallUpColumn(instantRow: player.instantRow, instantCol: player.instantCol) ?? 0
            case 0x7D: //down
                player.instantRow = tileMapping.getIndexWallDownColumn(instantRow: player.instantRow, instantCol: player.instantCol) ?? 0
            default:
                break
            }
            if let destination = (chao?.centerOfTile(atColumn: player.instantCol, row: player.instantRow)) {
                let action = SKAction.move(to: destination, duration: self.getDuration(pointA: instantPos, pointB: destination, speed: 1000))
                player.lock = true
                self.squares.first??.run(action, completion: {
                    player.lock = false
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
}

extension GameScene: MultipeerHandler {

    func peerReceivedInvitation(_ id: MCPeerID) -> Bool {
        // Teste
        if !player1 {
            players[0] = Player(id: id.description, name: "Teste1", colorPlayer: .blue, instantCol: 1, instantRow: 22)
            squares[0]?.name = id.description
            player1 = true
        } else {
            players[1] = Player(id: id.description, name: "Teste2", colorPlayer: .red, instantCol: 22, instantRow: 22)
            squares[1]?.name = id.description
        }

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

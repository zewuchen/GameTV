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
    private var spriteSquare: SKShapeNode?
    var player = Player(name: "Teste", colorPlayer: .blue, instantCol: 1, instantRow: 22)
    
    let tileMapping = TileMapping()
    
    override func didMove(to view: SKView) {
        self.chao = self.childNode(withName: "//chao") as? SKTileMapNode
        tileMapping.buildNumericMap(from: chao!)
        self.initShapes()

        MultipeerController.shared().delegate = self
    }
    
    func initShapes() {
        self.spriteSquare = SKShapeNode(rectOf: CGSize(width: 32, height: 32))
        guard let sSquare = self.spriteSquare else {
            fatalError()
        }
        sSquare.name = player.name
        sSquare.fillColor = player.colorPlayer.color

        if let positionSquare = (chao?.centerOfTile(atColumn: player.instantCol, row: player.instantRow)) {
            sSquare.position = positionSquare
            self.chao?.addChild(sSquare)
        }
    }
    
    override func keyDown(with event: NSEvent) {
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
                self.spriteSquare?.run(action, completion: {
                    self.player.lock = false
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
        print("Encontrado um usuário")
        return true
    }

    func receivedData(_ data: Data, from peerID: MCPeerID) {
        guard let texto = String(bytes: data, encoding: .utf8) else { return }
        let move = Movement(decode: texto)

        if !player.lock {
            guard let instantPos = (chao?.centerOfTile(atColumn: player.instantCol, row: player.instantRow)) else { return }
            switch move.type {
            case .right : //right
                player.instantCol = tileMapping.getIndexWallRightRow(instantRow: player.instantRow, instantCol: player.instantCol) ?? 0
            case .left: //left
                player.instantCol = tileMapping.getIndexWallLeftRow(instantRow: player.instantRow, instantCol: player.instantCol) ?? 0
            case .up: //up
                player.instantRow = tileMapping.getIndexWallUpColumn(instantRow: player.instantRow, instantCol: player.instantCol) ?? 0
            case .down: //down
                player.instantRow = tileMapping.getIndexWallDownColumn(instantRow: player.instantRow, instantCol: player.instantCol) ?? 0
            default:
                break
            }
            if let destination = (chao?.centerOfTile(atColumn: player.instantCol, row: player.instantRow)) {
                let action = SKAction.move(to: destination, duration: self.getDuration(pointA: instantPos, pointB: destination, speed: 1000))
                player.lock = true
                self.spriteSquare?.run(action, completion: {
                    self.player.lock = false
                })
            }
        }
        print("\(move.type) \(peerID)")
    }
}

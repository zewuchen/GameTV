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
    func removePlayer(player: Player)
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var chao : SKTileMapNode?
    private var squares: [SKShapeNode?] = []
    var players = [Player]()
    var totalPlayersInGame = 0
    var soundEffect = SoundManager()
    
    let tileMapping = TileMapping()
    var player1 = false // Teste
    var gameDelegate: GameSceneDelegate?
    
    override func didMove(to view: SKView) {
        self.chao = self.childNode(withName: "//chao") as? SKTileMapNode
        tileMapping.buildNumericMap(from: chao!)
        self.physicsWorld.contactDelegate = self
        self.initShapes()
        createGestures()
        totalPlayersInGame = players.count
        MultipeerController.shared().delegate = self
    }
    
    func initShapes() {
        for player in players {
            let square = SKShapeNode(rectOf: CGSize(width: 32, height: 32))
            square.fillColor = player.colorPlayer.color
            square.strokeColor = .clear
            square.name = player.id
            square.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: square.frame.width - 2, height: square.frame.height - 2))
            square.physicsBody?.isDynamic = true
            square.physicsBody?.affectedByGravity = false
            square.physicsBody?.collisionBitMask = 0
            square.physicsBody!.contactTestBitMask = UInt32.max
            square.physicsBody!.categoryBitMask = UInt32.max
            square.physicsBody?.allowsRotation = false
            square.physicsBody?.friction = 1.0
            let trail = SKShapeNode(rectOf: CGSize(width: 32, height: 32))
            trail.name = "trail"
            trail.strokeColor = .clear
            square.addChild(trail)
            if player.isPegador {
                let squarePegador = SKShapeNode(rectOf: CGSize(width: 14, height: 14))
                squarePegador.fillColor = .black
                squarePegador.strokeColor = .clear
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
    }
    
    func collisionBetween(square: SKNode, object: SKNode) {
        if object.name == "good" {
            soundEffect.play(sound: .playerCollision)
            destroy(square: square)
        } else if object.name == "bad" {
            soundEffect.play(sound: .playerEaten)
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
                let duration = self.getDuration(pointA: instantPos, pointB: destination, speed: 1000)
                self.createTrail(duration: duration, square: self.squares[0]!, direction: gesture.direction)
                let action = SKAction.move(to: destination, duration:duration)
                players[0].lock = true
                self.squares.first??.run(action, completion: {
                    self.players[0].lock = false
                })
            }
        }
    }
    
    func createTrail(duration: TimeInterval, square: SKShapeNode, direction: UISwipeGestureRecognizer.Direction) {
        guard let trail = square.childNode(withName: "trail") as? SKShapeNode else { return }
        var gradientDirection: GradientDirection = .left
        let color1 = CIColor(color: square.fillColor)
        let color2 = CIColor(red: color1.red, green: color1.green, blue: color1.blue, alpha: 0.0)
        if direction == .up {
            trail.yScale = 2
            trail.xScale = 1
            gradientDirection = .down
            trail.position = CGPoint(x: 0, y: -32)
        } else if direction == .down {
            trail.yScale = 2
            trail.xScale = 1
            gradientDirection = .up
            trail.position = CGPoint(x: 0, y: 32)
        } else if direction == .left {
            trail.xScale = 2
            trail.yScale = 1
            gradientDirection = .right
            trail.position = CGPoint(x: 32, y: 0)
        } else if direction == .right {
            trail.xScale = 2
            trail.yScale = 1
            gradientDirection = .left
            trail.position = CGPoint(x: -32, y: 0)
        }
        let texture = SKTexture(size: CGSize(width: 32, height: 32), color1: color1, color2: color2, direction: gradientDirection)
        trail.fillColor = .white
        trail.strokeColor = .clear
        trail.alpha = 0
        trail.fillTexture = texture
        let fadeIn = SKAction.fadeIn(withDuration: duration)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        trail.run(fadeIn) {
            trail.run(fadeOut)
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
    
    func unlockAll() {
        for player in players {
            player.lock = false
        }
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
            //Remover o playerB do jogo
            if totalPlayersInGame == 2 {
                gameDelegate?.endGame(winnerPlayer: gPlayerA)
            } else {
                totalPlayersInGame -= 1
                contact.bodyB.node?.removeFromParent()
                gPlayerA.lock = false
                guard let newRow = self.chao?.tileRowIndex(fromPosition: contact.bodyA.node!.position) else { fatalError() }
                guard let newColumn = self.chao?.tileColumnIndex(fromPosition: contact.bodyA.node!.position) else { fatalError() }
                gPlayerA.instantRow = newRow
                gPlayerA.instantCol = newColumn
                gameDelegate?.removePlayer(player: gPlayerB)
            }
        } else if !gPlayerA.isPegador && gPlayerB.isPegador {
            //Remover o playerA do jogo
            if totalPlayersInGame == 2 {
                gameDelegate?.endGame(winnerPlayer: gPlayerB)
            } else {
                totalPlayersInGame -= 1
                contact.bodyA.node?.removeFromParent()
                gPlayerB.lock = false
                guard let newRowB = self.chao?.tileRowIndex(fromPosition: contact.bodyB.node!.position) else { fatalError() }
                guard let newColumnB = self.chao?.tileColumnIndex(fromPosition: contact.bodyB.node!.position) else { fatalError() }
                gPlayerB.instantRow = newRowB
                gPlayerB.instantCol = newColumnB
                gameDelegate?.removePlayer(player: gPlayerA)
            }
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
        
        guard let player = playerAux else { return }
        guard let square = squareAux else { return }
        
        if !player.lock {
            guard let instantPos = (chao?.centerOfTile(atColumn: player.instantCol, row: player.instantRow)) else { return }
            var direction: UISwipeGestureRecognizer.Direction = .right
            switch move.type {

            case .right :
                direction = .right
                player.instantCol = tileMapping.getIndexWallRightRow(instantRow: player.instantRow, instantCol: player.instantCol) ?? 0
            case .left:
                direction = .left
                player.instantCol = tileMapping.getIndexWallLeftRow(instantRow: player.instantRow, instantCol: player.instantCol) ?? 0
            case .up:
                direction = .up
                player.instantRow = tileMapping.getIndexWallUpColumn(instantRow: player.instantRow, instantCol: player.instantCol) ?? 0
            case .down:
                direction = .down
                player.instantRow = tileMapping.getIndexWallDownColumn(instantRow: player.instantRow, instantCol: player.instantCol) ?? 0
            default:
                break
            }
            if let destination = (chao?.centerOfTile(atColumn: player.instantCol, row: player.instantRow)) {
                var duration: TimeInterval
                duration = self.getDuration(pointA: instantPos, pointB: destination, speed: 1000)

                if player.isPegador {
                    duration = self.getDuration(pointA: instantPos, pointB: destination, speed: 1150)
                }
                DispatchQueue.main.async {
                    self.createTrail(duration: duration, square: square, direction: direction)
                }
                let action = SKAction.move(to: destination, duration: self.getDuration(pointA: instantPos, pointB: destination, speed: 1000))
                player.lock = true
                square.run(action, completion: {
                    player.lock = false
                    self.soundEffect.play(sound: .wallCollision)
                })
            }
        }
    }
}



public enum GradientDirection {
    case up
    case down
    case left
    case right
    case upLeft
    case upRight
}

public extension SKTexture {
    
    convenience init(size: CGSize, color1: CIColor, color2: CIColor, direction: GradientDirection = .up) {
        
        let context = CIContext(options: nil)
        let filter = CIFilter(name: "CILinearGradient")
        var startVector: CIVector
        var endVector: CIVector
        
        filter!.setDefaults()
        
        switch direction {
        case .up:
            startVector = CIVector(x: size.width * 0.5, y: 0)
            endVector = CIVector(x: size.width * 0.5, y: size.height)
        case .left:
            startVector = CIVector(x: size.width, y: size.height * 0.5)
            endVector = CIVector(x: 0, y: size.height * 0.5)
        case .upLeft:
            startVector = CIVector(x: size.width, y: 0)
            endVector = CIVector(x: 0, y: size.height)
        case .upRight:
            startVector = CIVector(x: 0, y: 0)
            endVector = CIVector(x: size.width, y: size.height)
        case .right:
            endVector = CIVector(x: size.width, y: size.height * 0.5)
            startVector = CIVector(x: 0, y: size.height * 0.5)
        case .down:
            endVector = CIVector(x: size.width * 0.5, y: 0)
            startVector = CIVector(x: size.width * 0.5, y: size.height)
        }
        
        filter!.setValue(startVector, forKey: "inputPoint0")
        filter!.setValue(endVector, forKey: "inputPoint1")
        filter!.setValue(color1, forKey: "inputColor0")
        filter!.setValue(color2, forKey: "inputColor1")
        
        let image = context.createCGImage(filter!.outputImage!, from: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        self.init(cgImage: image!)
    }
    
}

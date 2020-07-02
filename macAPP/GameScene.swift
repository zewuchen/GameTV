//
//  GameScene.swift
//  TileTest
//
//  Created by Felipe Petersen on 30/06/20.
//  Copyright © 2020 Felipe Petersen. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var chao : SKTileMapNode?
    private var spriteSquare: SKShapeNode?
    
    let tileMapping = TileMapping()
    var instantCol = 0
    var instantRow = 0
    var lockPlayer = false
    
    override func didMove(to view: SKView) {
        
//        self.square = self.childNode(withName: "//square") as? SKNode
//        square!.position = CGPoint(x: 0, y: 0)
//        self.square
        // Get label node from scene and store it for use later
        self.chao = self.childNode(withName: "//chao") as? SKTileMapNode
        tileMapping.buildNumericMap(from: chao!)
        self.initShapes()

//        let position = chao?.convert(square!.position, to: square!)
//        let column = chao?.tileColumnIndex(fromPosition: position!)
//        let row = chao?.tileRowIndex(fromPosition: position!)
//        print(column, row)
//
//        let destination = (chao?.centerOfTile(atColumn: 1, row: 22))!
//        instantCol = 1
//        instantRow = 22
////        let action = SKAction.move(to: destination, duration: 0)
////        square.run(action)
//        square!.position = destination
//        print(square!.position)
//
//        let position2 = chao?.convert(square.position, to: square)
//        let column2 = chao?.tileColumnIndex(fromPosition: position2!)
//        let row2 = chao?.tileRowIndex(fromPosition: position2!)
//        print(column2, row2)
        
        
        // Create shape node to use during mouse interaction
//        let w = (self.size.width + self.size.height) * 0.05
//        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
//
//        if let spinnyNode = self.spinnyNode {
//            spinnyNode.lineWidth = 2.5
//
//            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
//            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
//                                              SKAction.fadeOut(withDuration: 0.5),
//                                              SKAction.removeFromParent()]))
//        }
    }
    
    func initShapes() {
        self.spriteSquare = SKShapeNode(rectOf: CGSize(width: 32, height: 32))
        guard let sSquare = self.spriteSquare else {
            fatalError()
        }
        sSquare.name = "player1"
        sSquare.fillColor = .blue
//        sSquare.position = CGPoint(x: 0, y: 0)
        let destination = (chao?.centerOfTile(atColumn: 1, row: 22))!
        instantCol = 1
        instantRow = 22

        sSquare.position = destination
        self.chao?.addChild(sSquare)
    }
    
//
//    func touchDown(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.green
//            self.addChild(n)
//        }
//    }
//
//    func touchMoved(toPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.blue
//            self.addChild(n)
//        }
//    }
//
//    func touchUp(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.red
//            self.addChild(n)
//        }
//    }
//
//    override func mouseDown(with event: NSEvent) {
//        self.touchDown(atPoint: event.location(in: self))
//    }
//
//    override func mouseDragged(with event: NSEvent) {
//        self.touchMoved(toPoint: event.location(in: self))
//    }
//
//    override func mouseUp(with event: NSEvent) {
//        self.touchUp(atPoint: event.location(in: self))
//    }
    
    override func keyDown(with event: NSEvent) {
        if !lockPlayer {
            let character = Int16(event.keyCode)
            let instantPos = (chao?.centerOfTile(atColumn: instantCol, row: instantRow))!
            switch character {
            case 0x7C : //right
                self.instantCol = tileMapping.getIndexWallRightRow(instantRow: instantRow, instantCol: instantCol) ?? 0
            case 0x7B: //left
                self.instantCol = tileMapping.getIndexWallLeftRow(instantRow: instantRow, instantCol: instantCol) ?? 0
            case 0x7E: //up
                self.instantRow = tileMapping.getIndexWallUpColumn(instantRow: instantRow, instantCol: instantCol) ?? 0
            case 0x7D: //down
                self.instantRow = tileMapping.getIndexWallDownColumn(instantRow: instantRow, instantCol: instantCol) ?? 0
            default:
                break
            }
            let destination = (chao?.centerOfTile(atColumn: instantCol, row: instantRow))!
            let action = SKAction.move(to: destination, duration: self.getDuration(pointA: instantPos, pointB: destination, speed: 1000))
            lockPlayer = true
            self.spriteSquare?.run(action, completion: {
                self.lockPlayer = false
            })
        }
//        self.spriteSquare?.position = destination
        
        
//        instantCol = instantCol + 1
//        let destination = (chao?.centerOfTile(atColumn: instantCol, row: instantRow))!
//        self.square?.position = destination
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

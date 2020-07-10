//
//  ScoreController.swift
//  tvAPP
//
//  Created by Felipe Petersen on 08/07/20.
//  Copyright © 2020 Zewu Chen. All rights reserved.
//

import Foundation
import UIKit

enum ScorePosition {
    case left
    case right
}

class ScoreController: UIView {
    
    let colors: [ColorPlayer] = [.blue, .red, .green]
    var viewHeight: CGFloat?
    var viewWidth: CGFloat?
    var scorePosition: ScorePosition = .left
    var scoreViews = [ScoreView]()
    
//    init(scorePosition: ScorePosition, size: CGSize, position: CGPoint) {
//        self.scorePosition = scorePosition
//        super.init(frame: CGRect(x: position.x, y: position.y, width: size.width, height: size.height))
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func draw(_ rect: CGRect) {
        self.viewWidth = rect.width
        self.viewHeight = rect.height
        self.initViews()
    }
    
    func initViews() {
        let count = self.colors.count
        var heightForView = Int(viewHeight ?? 0) / count
        let size = CGSize(width: 0, height: heightForView)
        var scoreView: ScoreView?
        var position: CGPoint?

        for i in 0..<colors.count {
            
            switch scorePosition {
            case .left:
                position = CGPoint(x: 0, y: Int(heightForView) * i)
            case .right:
                let width = viewWidth! - SelectionState.notSelected.rawValue
                position = CGPoint(x: width, y: CGFloat(heightForView) * CGFloat(i))
            default:
                break
            }
            
            scoreView = ScoreView(color: colors[i], size: size, position: position!)
            self.addSubview(scoreView!)
            self.scoreViews.append(scoreView!)
        }
    }
    
    func updateBasedOnPlayers(players: [Player]) {
        for player in players {
            let view = scoreViews[player.menuPosition.1]
            view.state = player.selectionState
            view.animateOwnState(scorePosition: scorePosition, width: self.viewWidth ?? 0)
//            view.createPoints()
        }
    }
}

class ScoreView: UIView {
    var color: ColorPlayer?
    var position: CGPoint?
    var state: SelectionState = .notSelected

    init(color: ColorPlayer, size: CGSize, position: CGPoint) {
        self.color = color
        self.position = position
        super.init(frame: CGRect(x: position.x, y: position.y, width: state.rawValue, height: size.height))
        self.backgroundColor = color.color
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func animateOwnState(scorePosition: ScorePosition, width: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            switch scorePosition {
            case .left:
                self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: width, height: self.frame.height)
            case .right:
                self.frame = CGRect(x: 0, y: self.frame.minY, width: width, height: self.frame.height)
            }
        }
        createPoints()
    }
    
    func createPoints() {
        let sizeConstant: CGFloat = 0.5
        let pointSize = CGSize(width: self.frame.width * sizeConstant, height: self.frame.width * sizeConstant)
        let pointsView = PointsView(frame: CGRect(x: self.frame.width/2 - pointSize.width/2, y: self.frame.height/2 - pointSize.width/2, width: pointSize.width, height: pointSize.height))
        self.addSubview(pointsView)
    }
}

class PointsView: UIView {
    var totalPoints = 4
    
    override func draw(_ rect: CGRect) {
        distributeScore()
    }
    
    func distributeScore() {
        let circleConst:CGFloat = 0.7
        let totalCol = totalPoints/2
        let totalRow = totalCol
        for col in 0..<totalCol {
            for row in 0..<totalRow {
                let circleViewOwner = UIView(frame: CGRect(x: self.frame.width/CGFloat(totalCol) * CGFloat(col) , y: self.frame.width/CGFloat(totalCol) * CGFloat(row), width: self.frame.width/CGFloat(totalCol), height: self.frame.height/CGFloat(totalRow)))
                
                let circleSize = CGSize(width: circleViewOwner.frame.width * circleConst, height: circleViewOwner.frame.height * circleConst)
                let circleView = UIView(frame: CGRect(x: circleViewOwner.frame.width/2 - circleSize.width/2, y: circleViewOwner.frame.height/2 - circleSize.width/2, width: circleSize.width, height: circleSize.height))
                circleView.layer.cornerRadius = circleView.frame.height/2
                circleView.backgroundColor = .black
                circleViewOwner.addSubview(circleView)
                self.addSubview(circleViewOwner)
            }
        }
    }
}
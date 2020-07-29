//
//  ColorSelectionView.swift
//  tvAPP
//
//  Created by Felipe Petersen on 03/07/20.
//  Copyright © 2020 Zewu Chen. All rights reserved.
//

import Foundation
import UIKit

class SelectionController: UIView {
    
    let colors: [[ColorPlayer]] = DesignSystem().getMenuColors()
    var viewHeight: CGFloat?
    var viewWidth: CGFloat?
    var selectionViews = [[SelectionView]]()
    
    override func draw(_ rect: CGRect) {
        self.viewWidth = rect.width
        self.viewHeight = rect.height
        self.backgroundColor = DesignSystem.Colors.gray
        initViews()
    }
    
    func initViews() {
        let count = (self.colors[0].count)
        let heightForView = Int(viewHeight ?? 0) / count
        
        let size = CGSize(width: 0, height: heightForView)
        var selectionView: SelectionView?
        
        for horizontal in 0..<colors.count {
            self.selectionViews.append([SelectionView]())
            var column = 0
            for vertical in 0..<colors[horizontal].count {
                var position: CGPoint?
                if horizontal == 0 {
                    column = 0
                    position = CGPoint(x: 0, y: Int(heightForView) * vertical)
                } else {
                    let width = viewWidth! - SelectionState.notSelected.rawValue
                    column = 1
                    position = CGPoint(x: width, y: CGFloat(heightForView) * CGFloat(vertical))
                }
                selectionView = SelectionView(color: colors[horizontal][vertical], size: size, position: position!, column: column)
                self.addSubview(selectionView!)
                self.selectionViews[horizontal].append(selectionView!)
                
            }
        }
    }
    
    //Passa a posição que está no momento, sendo coluna e row, e o tipo de movimento para calcular a posicao final
    func changePos(instantPos: (Int,Int), swipe: MovementType) -> (Int, Int) {
        var finalPos = instantPos
        switch swipe {
        case .down:
            self.selectionViews[finalPos.0][finalPos.1].animateTo(state: .notSelected, newColumn: nil)
            if finalPos.1 + 1 == selectionViews[finalPos.0].count {
                finalPos.1 = 0
            } else {
                finalPos.1 = finalPos.1 + 1
            }
            self.selectionViews[finalPos.0][finalPos.1].animateTo(state: .preSelected, newColumn: nil)
        case .up:
            self.selectionViews[finalPos.0][finalPos.1].animateTo(state: .notSelected, newColumn: nil)
            if finalPos.1 - 1 < 0 {
                finalPos.1 = selectionViews[finalPos.0].count - 1
            } else {
                finalPos.1 = finalPos.1 - 1
            }
            self.selectionViews[finalPos.0][finalPos.1].animateTo(state: .preSelected, newColumn: nil)
        case .left:
            self.selectionViews[finalPos.0][finalPos.1].animateTo(state: .notSelected, newColumn: nil)
            if !(finalPos.0 - 1 < 0) {
                finalPos.0 = finalPos.0 - 1
            }
            self.selectionViews[finalPos.0][finalPos.1].animateTo(state: .preSelected, newColumn: 0)
        case .right:
            if finalPos.0 + 1 == (selectionViews.count - 1) {
                self.selectionViews[finalPos.0][finalPos.1].animateTo(state: .notSelected, newColumn: nil)
                finalPos.0 = finalPos.0 + 1
                self.selectionViews[finalPos.0][finalPos.1].animateTo(state: .preSelected, newColumn: 1)
            }
        default:
            break
        }
        return finalPos
    }
    
    func selectItem(instantPos: (Int,Int)) -> Bool /*worked*/ {
        //TODO:- CheckAvailable
        self.selectionViews[instantPos.0][instantPos.1].animateTo(state: .selected, newColumn: nil)
        return true
    }
    
    func getColor(instantPos: (Int,Int)) -> ColorPlayer {
        return self.selectionViews[instantPos.0][instantPos.1].color ?? .blue
    }
    
    func deselectAllViews() {
        for column in selectionViews  {
            for view in column {
                view.state = .notSelected
            }
        }
    }
    
    func updateBasedOnPlayersPosition(players: [Player]) {
        deselectAllViews()
//        var createControl = false
        for column in selectionViews {
            for view in column {
                view.removeSubViews()
            }
        }
        for player in players {
            let view = selectionViews[player.menuPosition.0][player.menuPosition.1]
//            view.removeSubViews()
            if view.state != .selected {
                view.state = player.selectionState
            }
            if player.id == players[0].id {
                view.createControl()
//                createControl = true
            }
        }
        for column in selectionViews  {
            for view in column {
//                view.animateOwnState(shouldCreateControl: createControl)
                view.animateOwnState()
            }
        }
    }
    
    func getLimitsOfColors() -> (Int, Int) {
        return (self.colors.count, self.colors[0].count)
    }
}

class SelectionView: UIView {
    
    var color: ColorPlayer?
    var state: SelectionState = .notSelected
    var column: Int?
    var position: CGPoint?
    lazy var imageView = UIImageView(frame: CGRect(x: self.frame.width, y: self.frame.height/2, width: 50, height: 50))
    lazy var controlView = UIView(frame: CGRect(x: self.frame.width + state.rawValue - 50, y: self.frame.height/2 - 50, width: 100, height: 100))

    init(color: ColorPlayer, size: CGSize, position: CGPoint, column: Int) {
        self.color = color
        self.column = column
        self.position = position
        super.init(frame: CGRect(x: position.x, y: position.y, width: state.rawValue, height: size.height))
        self.backgroundColor = color.color
        //        self.draw(self.frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func animateTo(state: SelectionState, newColumn: Int?) {
        self.state = state
        if let newColumn = newColumn {
            self.column = newColumn
        }
        UIView.animate(withDuration: 0.3) {
            switch self.column {
            case 0:
                self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: state.rawValue, height: self.frame.height)
                
            case 1:
                self.frame = CGRect(x: self.position!.x + SelectionState.notSelected.rawValue - state.rawValue, y: self.frame.minY, width: state.rawValue, height: self.frame.height)
            default:
                break
            }
        }
    }
    
    func animateOwnState() {
        UIView.animate(withDuration: 0.3) {
            if self.frame.minX > 0 {
                self.frame = CGRect(x: self.position!.x + SelectionState.notSelected.rawValue - self.state.rawValue, y: self.frame.minY, width: self.state.rawValue, height: self.frame.height)
            } else {
                self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: self.state.rawValue, height: self.frame.height)
            }
//             self.controlView.frame = self.frame
        }
        
//        if shouldCreateControl {
//            createControl()
//        }
    }
    
    func createControl() {
//        let imageView = UIImageView(frame: CGRect(x: self.frame.width, y: self.frame.height/2, width: 50, height: 50))
        controlView.layer.cornerRadius = 50
        controlView.backgroundColor = DesignSystem.Colors.gray
        controlView.layer.borderWidth = 5
        controlView.layer.borderColor = self.color?.color.cgColor
        controlView.clipsToBounds = true
//        imageView.frame = CGRect(x: self.frame.width + state.rawValue, y: self.frame.height/2 - 25, width: 50, height: 50)
        if self.frame.minX > 0 {
            controlView.frame = CGRect(x: -50, y: self.frame.height/2 - 50, width: 100, height: 100)
        } else {
            controlView.frame = CGRect(x: self.state.rawValue - 50 , y: self.frame.height/2 - 50, width: 100, height: 100)
        }
        controlView.addSubview(imageView)
        controlView.isHidden = false
        imageView.frame = CGRect(x: 25, y: 25, width: 50, height: 50)
        imageView.tintColor = self.color?.color
        imageView.isHidden = false
        imageView.image = UIImage(named: "control")
        imageView.contentMode = .scaleAspectFit
        self.addSubview(controlView)
//        self.addSubview(imageView)
    }
    
    func removeSubViews() {
        controlView.isHidden = true
    }
}

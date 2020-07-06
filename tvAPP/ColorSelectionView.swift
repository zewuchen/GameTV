//
//  ColorSelectionView.swift
//  tvAPP
//
//  Created by Felipe Petersen on 03/07/20.
//  Copyright © 2020 Zewu Chen. All rights reserved.
//

import Foundation
import UIKit

enum SelectionState: CGFloat {
    case notSelected = 50
    case preSelected = 200
    case selected = 300
}

class SelectionController: UIView {

    let colors: [[UIColor]] = [[.orange, .blue, .green], [.black, .brown, .red]]
    var viewHeight: CGFloat?
    var viewWidth: CGFloat?
    var selectionViews = [[SelectionView]]()
    
    override func draw(_ rect: CGRect) {
        self.viewWidth = rect.width
        self.viewHeight = rect.height
        self.backgroundColor = .gray
        initViews()
    }
    
    func initViews() {
        let count = (self.colors[0].count)
        var heightForView = Int(viewHeight ?? 0) / count
        
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
}

class SelectionView: UIView {
    
    var color: UIColor?
    var state: SelectionState = .notSelected
    var column: Int?
    var position: CGPoint?
    
    init(color: UIColor, size: CGSize, position: CGPoint, column: Int) {
        self.color = color
        self.column = column
        self.position = position
        super.init(frame: CGRect(x: position.x, y: position.y, width: state.rawValue, height: size.height))
        self.backgroundColor = color
//        self.draw(self.frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
//
//    override func draw(_ rect: CGRect) {
//        self.backgroundColor = color
//        self.frame = rect
//    }
    func animateTo(state: SelectionState, newColumn: Int?) {
        self.state = state
        if let newColumn = newColumn {
         self.column = newColumn
        }
        UIView.animate(withDuration: 0.5) {
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
}

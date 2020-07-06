//
//  Player.swift
//  tvAPP
//
//  Created by Zewu Chen on 06/07/20.
//  Copyright © 2020 Zewu Chen. All rights reserved.
//
import UIKit

public enum ColorPlayer {
    case black
    case blue
    case red

    var color: UIColor {
        switch self {
        case .black:
            return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        case .blue:
            return #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        case .red:
            return #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        default:
            return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
}

class Player {
    let name: String
    var colorPlayer: ColorPlayer
    var score: Int
    var instantCol: Int
    var instantRow: Int

    public init(_ name: String, _ colorPlayer: ColorPlayer, _ score: Int = 0, _ instantCol: Int, _ instantRow: Int) {
        self.name = name
        self.colorPlayer = colorPlayer
        self.score = score
        self.instantCol = instantCol
        self.instantRow = instantRow
    }
}

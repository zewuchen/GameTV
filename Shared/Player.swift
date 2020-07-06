//
//  Player.swift
//  tvAPP
//
//  Created by Zewu Chen on 06/07/20.
//  Copyright © 2020 Zewu Chen. All rights reserved.
//
#if !os(macOS)
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
#else
import AppKit

public enum ColorPlayer {
    case black
    case blue
    case red

    var color: NSColor {
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
#endif

class Player {
    let name: String
    var colorPlayer: ColorPlayer
    var score: Int
    var instantCol: Int
    var instantRow: Int
    var lock: Bool

    public init(name: String, colorPlayer: ColorPlayer, score: Int = 0, instantCol: Int, instantRow: Int, lock: Bool = false) {
        self.name = name
        self.colorPlayer = colorPlayer
        self.score = score
        self.instantCol = instantCol
        self.instantRow = instantRow
        self.lock = lock
    }
}

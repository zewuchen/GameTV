//
//  Player.swift
//  tvAPP
//
//  Created by Zewu Chen on 06/07/20.
//  Copyright © 2020 Zewu Chen. All rights reserved.
//

enum SelectionState: CGFloat {
    #if os(iOS)
    case notSelected = 30
    case preSelected = 150
    case selected = 160
    #else
    case notSelected = 100
    case preSelected = 200
    case selected = 300
    #endif
}

#if !os(macOS)
import UIKit
#else
import AppKit
#endif

public enum ColorPlayer {
    case blue
    case red
    case green
    case purple
    case orange
    case yellow

    #if !os(macOS)
    var color: UIColor {
        switch self {
        case .blue:
            return DesignSystem.Colors.blue
        case .red:
            return DesignSystem.Colors.red
        case .green:
            return DesignSystem.Colors.green
        case .purple:
            return DesignSystem.Colors.purple
        case .orange:
            return DesignSystem.Colors.orange
        case .yellow:
            return DesignSystem.Colors.yellow
        }
    }
    #else
    var color: NSColor {
        switch self {
        case .blue:
            return DesignSystem.Colors.blue
        case .red:
            return DesignSystem.Colors.red
        case .green:
            return DesignSystem.Colors.green
        case .purple:
            return DesignSystem.Colors.purple
        case .orange:
            return DesignSystem.Colors.orange
        case .yellow:
            return DesignSystem.Colors.yellow
        }
    }
    #endif
}

class Player {
    let id: String
    let name: String
    var colorPlayer: ColorPlayer
    var score: Int
    var instantCol: Int
    var instantRow: Int
    var lock: Bool
    var isPegador: Bool
    var selectionState: SelectionState
    var menuPosition: (Int,Int)
    
  

    public init(id: String, name: String, colorPlayer: ColorPlayer, score: Int = 0, instantCol: Int = 0, instantRow: Int = 0, lock: Bool = false, selectionState: SelectionState = .preSelected, menuPosition: (Int,Int) = (0,0), isPegador: Bool = false) {
        self.id = id
        self.name = name
        self.colorPlayer = colorPlayer
        self.score = score
        self.instantCol = instantCol
        self.instantRow = instantRow
        self.lock = lock
        self.isPegador = isPegador
        self.selectionState = selectionState
        self.menuPosition = menuPosition
    }
}


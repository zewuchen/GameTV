//
//  DesignSystem.swift
//  tvAPP
//
//  Created by Zewu Chen on 06/07/20.
//  Copyright © 2020 Zewu Chen. All rights reserved.
//
#if !os(macOS)
import UIKit
#else
import AppKit
#endif

public class DesignSystem {

    public static func shared() -> DesignSystem {
        return sharedInstance
    }

    private static let sharedInstance: DesignSystem = {
        let shared = DesignSystem()
        return shared
    }()

    public class Colors {

        static let blue = #colorLiteral(red: 0.4666666667, green: 0.7647058824, blue: 0.9333333333, alpha: 1)
        static let red = #colorLiteral(red: 0.8941176471, green: 0.2862745098, blue: 0.2862745098, alpha: 1)
        static let green = #colorLiteral(red: 0.4705882353, green: 0.9254901961, blue: 0.3137254902, alpha: 1)
        static let purple = #colorLiteral(red: 0.6549019608, green: 0.3137254902, blue: 0.9254901961, alpha: 1)
        static let orange = #colorLiteral(red: 0.9254901961, green: 0.4941176471, blue: 0.3137254902, alpha: 1)
        static let yellow = #colorLiteral(red: 0.9254901961, green: 0.862745098, blue: 0.3137254902, alpha: 1)
        static let white = #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1)
        static let gray = #colorLiteral(red: 0.1450980392, green: 0.1450980392, blue: 0.1450980392, alpha: 1)

    }
    
    func getMenuColors() -> [[ColorPlayer]] {
        return [[.blue, .red, .green], [.purple, .orange, .yellow]]
    }
    
    func getRightPointsColor() -> [ColorPlayer] {
        return [.blue, .red, .green]
    }

    func getLeftPointsColor() -> [ColorPlayer] {
        return [.purple, .orange, .yellow]
    }
    
}


public class DesignSystemMap1 {
    
    var possiblePositions: [(Int, Int)] = [(1, 15), (21, 15), (1, 1), (12, 8), (21, 1), (11, 1)]
    var auxPossible:  [(Int, Int)] = [(1, 15), (21, 15), (1, 1), (12, 8), (21, 1), (11, 1)]
    public static func shared() -> DesignSystemMap1 {
        return sharedInstance
    }

    private static let sharedInstance: DesignSystemMap1 = {
        let shared = DesignSystemMap1()
        return shared
    }()

    func getRandomPosition() -> (Int, Int) {
        guard let pos = auxPossible.randomElement() else { return (0,0) }
        auxPossible.removeAll { (position) -> Bool in
            return pos == position
        }
        return pos
    }
    
    func resetPos() {
        self.auxPossible = possiblePositions
    }
}

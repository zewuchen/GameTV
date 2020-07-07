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

        #if !os(macOS)
        static func allColors() -> [UIColor] {
            return [
                Colors.blue,
                Colors.red,
                Colors.green,
                Colors.purple,
                Colors.orange,
                Colors.yellow,
                Colors.white,
                Colors.gray
            ]
        }

        static func leftColumnColors() -> [UIColor] {
            return [
                Colors.blue,
                Colors.red,
                Colors.green
            ]
        }

        static func rightColumnColors() -> [UIColor] {
            return [
                Colors.purple,
                Colors.orange,
                Colors.yellow
            ]
        }
        #else
        static func allColors() -> [NSColor] {
            return [
                Colors.blue,
                Colors.red,
                Colors.green,
                Colors.purple,
                Colors.orange,
                Colors.yellow,
                Colors.white,
                Colors.gray
            ]
        }

        static func leftColumnColors() -> [NSColor] {
            return [
                Colors.blue,
                Colors.red,
                Colors.green
            ]
        }

        static func rightColumnColors() -> [NSColor] {
            return [
                Colors.purple,
                Colors.orange,
                Colors.yellow
            ]
        }
        #endif
    }

}


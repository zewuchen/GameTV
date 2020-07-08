//
//  CommandSystem.swift
//  tvAPP
//
//  Created by Zewu Chen on 08/07/20.
//  Copyright © 2020 Zewu Chen. All rights reserved.
//

public enum Command {
    case start
    case pause
    case `continue`
    case newGame
    case end
    case invalid
}

public struct CommandSystem {
    var decode: String

    var command: Command {
        switch decode {
        case "START":
            return .start
        case "PAUSE":
            return .pause
        case "CONTINUE":
            return .continue
        case "NEWGAME":
            return .newGame
        case "END":
            return .end
        default:
            return .invalid
        }
    }
}

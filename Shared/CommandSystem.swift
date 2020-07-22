//
//  CommandSystem.swift
//  tvAPP
//
//  Created by Zewu Chen on 08/07/20.
//  Copyright © 2020 Zewu Chen. All rights reserved.
//

public enum Command {
    case start // Tela de seleção -> Tela de controle do jogo
    case pause // Jogo pausado (Continua na tela de controle do jogo)
    case `continue` // Retomada do jogo pausado (Continua na tela de controle do jogo)
    case restart // Fim de jogo -> Recomeçar jogo (Continua na tela de controle do jogo)
    case end // Fim de jogo (Continua na tela de controle do jogo)
    case newGame // Fim de jogo -> Tela de seleção
    case lockColor // Player escolheu a cor dele
    case confirmedColor // Confirmação que a cor foi escolhida pela AppleTV
    case cannotConfirmeColor // Não conseguiu confirmar a cor do jogador na AppleTV (alguém já pode ter selecionado)
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
        case "RESTART":
            return .restart
        case "END":
            return .end
        case "NEWGAME":
            return .newGame
        case "LOCKCOLOR":
            return .lockColor
        case "CONFIRMEDCOLOR":
            return .confirmedColor
        case "CANNOTCOLOR":
            return .cannotConfirmeColor
        default:
            return .invalid
        }
    }
}

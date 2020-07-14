//
//  System.swift
//  tvAPP
//
//  Created by Zewu Chen on 14/07/20.
//  Copyright © 2020 Zewu Chen. All rights reserved.
//

public class System {

    public static func shared() -> System {
        return sharedInstance
    }

    private static let sharedInstance: System = {
        let shared = System()
        return shared
    }()

    static let soundManager: SoundManager = SoundManager()

}

//
//  TileMapping.swift
//  TileTest
//
//  Created by Felipe Petersen on 01/07/20.
//  Copyright © 2020 Felipe Petersen. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class TileMapping {
    
    var map: SKTileMapNode?
    var numericMap = [[Int]]()
    
    func buildNumericMap(from map: SKTileMapNode) {
        self.map = map
        
        let position = CGPoint(x: 0, y: 0)
        let column = self.map?.tileColumnIndex(fromPosition: position)
        let row = self.map?.tileRowIndex(fromPosition: position)
        
        guard let totalRows = self.map?.numberOfRows else {
            fatalError()
        }
        guard let totalColumns = self.map?.numberOfColumns else {
            fatalError()
        }
        
        for row in 0..<totalRows {
            var appendRow = [Int]()
            for col in 0..<totalColumns {
                let tile = self.map?.tileDefinition(atColumn: col, row: row)
                appendRow.append(tile == nil ? 0 : 1)
            }
            self.numericMap.append(appendRow)
        }
    }
    
    func getIndexWallRightRow(instantRow: Int, instantCol: Int) -> Int? {
        guard let totalColumns = self.map?.numberOfColumns else {
            fatalError()
        }
        for col in instantCol..<totalColumns {
            if self.numericMap[instantRow][col] == 0 {
                return col - 1
            }
        }
        return nil
    }
    
    func getIndexWallLeftRow(instantRow: Int, instantCol: Int) -> Int? {
        let countdown = Countdown(count: instantCol)
        for col in countdown{
            if self.numericMap[instantRow][col] == 0 {
                return col + 1
            }
        }
        return nil
    }
    
    func getIndexWallUpColumn(instantRow: Int, instantCol: Int) -> Int? {
        guard let totalRows = self.map?.numberOfRows else {
            fatalError()
        }
        //        var actualPos =
        
        for row in instantRow..<totalRows {
            if self.numericMap[row][instantCol] == 0 {
                return row - 1
            }
        }
        return nil
    }
    
    func getIndexWallDownColumn(instantRow: Int, instantCol: Int) -> Int? {
        let countdown = Countdown(count: instantRow)
        for row in countdown {
            if self.numericMap[row][instantCol] == 0 {
                return row + 1
            }
        }
        return nil
    }
}

struct Countdown: Sequence, IteratorProtocol {
    var count: Int
    
    mutating func next() -> Int? {
        if count == -1 {
            return nil
        } else {
            defer { count -= 1 }
            return count
        }
    }
}

//
//  Swirl.swift
//  SwirlGame
//
//  Created by Techjini on 13/12/16.
//  Copyright © 2016 Techjini. All rights reserved.
//

import Foundation
import SpriteKit

// MARK: - CookieType
enum SwirlType: Int {
    case unknown = 0, green, orange, blue, pink
    
    var spriteName: String {
        let spriteNames = [
            "Croissant",
            "Cupcake",
            "Danish",
            "Donut"]
        
        return spriteNames[rawValue - 1]
    }
    
    var highlightedSpriteName: String {
        return spriteName + "-Highlighted"
    }
    
    var description: String {
        return spriteName
    }
    
    static func random() -> SwirlType {
        return SwirlType(rawValue: Int(arc4random_uniform(4)) + 1)!
    }

}

// MARK: - Cookie
func ==(lhs: Swirl, rhs: Swirl) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
}

// MARK: - Swirl
class Swirl {
    var column: Int
    var row: Int
    let swirlType: SwirlType
    var sprite: SKSpriteNode?
    
    init(column: Int, row: Int, swirlType: SwirlType) {
        self.column = column
        self.row = row
        self.swirlType = swirlType
    }
    
    var description: String {
        return "type:\(swirlType) square:(\(column),\(row))"
    }
    
    var hashValue: Int {
        return row*10 + column
    }
}

extension Swirl: Hashable,CustomStringConvertible {}

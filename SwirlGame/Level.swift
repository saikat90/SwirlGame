//
//  Level.swift
//  SwirlGame
//
//  Created by Techjini on 12/12/16.
//  Copyright © 2016 Techjini. All rights reserved.
//


import Foundation

let NumColumns = 10
let NumRows = 10

class Level {
    
    // MARK: Properties
    
    // The 2D array that keeps track of where the swirls are.
    fileprivate var swirls = Array2D<Swirl>(columns: NumColumns, rows: NumRows)
    
    // The 2D array that contains the layout of the level.
    fileprivate var tiles = Array2D<Tile>(columns: NumColumns, rows: NumRows)
    
    var removeMatchSet = Set<Chain>()
    
    // MARK: Initialization
    
    // Create a level by loading it from a file.
    init(filename: String) {
        guard let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename: filename) else { return }
        // The dictionary contains an array named "tiles". This array contains
        // one element for each row of the level. Each of those row elements in
        // turn is also an array describing the columns in that row. If a column
        // is 1, it means there is a tile at that location, 0 means there is not.
        guard let tilesArray = dictionary["tiles"] as? [[Int]] else { return }
        
        // Loop through the rows...
        for (row, rowArray) in tilesArray.enumerated() {
            // Note: In Sprite Kit (0,0) is at the bottom of the screen,
            // so we need to read this file upside down.
            let tileRow = NumRows - row - 1
            
            // Loop through the columns in the current r
            for (column, value) in rowArray.enumerated() {
                // If the value is 1, create a tile object.
                if value == 1 {
                    tiles[column, tileRow] = Tile()
                }
            }
        }
    }
    
    
    // MARK: Level Setup
    
    // Fills up the level with new swirl objects
    func shuffle() -> Set<Swirl> {
        return createInitialSwirls()
    }
    
    fileprivate func createInitialSwirls() -> Set<Swirl> {
        var set = Set<Swirl>()
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if tiles[column, row] != nil {
                    let swirlType = SwirlType.random() // Keep 'var'. Will be mutated later
                    
                    let swirl = Swirl(column: column, row: row, swirlType: swirlType)
                    swirls[column, row] = swirl
                    
                    set.insert(swirl)
                }
            }
        }
        return set
    }
    
    
    // MARK: Query the level
    
    // Determines whether there's a tile at the specified column and row.
    func tileAt(column: Int, row: Int) -> Tile? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return tiles[column, row]
    }
    
    // Returns the swirl at the specified column and row, or nil when there is none.
    func swirlAt(column: Int, row: Int) -> Swirl? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return swirls[column, row]
    }
    
    // MARK: Detecting Matches
    func verticalMatchUpward(swirl: Swirl) {
        let chain = Chain(chainType: .vertical)
        let swirlArray = removeMatchSet.map({ Array($0.swirls) }).reduce([], +)
        if swirl.row + 1 < NumRows &&
            swirls[swirl.column, swirl.row + 1]?.swirlType == swirl.swirlType &&
            !swirlArray.contains(swirls[swirl.column, swirl.row + 1]!)  {
            chain.add(swirl: swirls[swirl.column, swirl.row + 1]!)
            removeMatchSet.insert(chain)
            verticalMatchUpward(swirl: swirls[swirl.column, swirl.row + 1]!)
            horizontalMatchForward(swirl: swirls[swirl.column, swirl.row + 1]!)
            horizontalMatchBackward(swirl: swirls[swirl.column, swirl.row + 1]!)
        }
    }
    
    func verticalMatchDownward(swirl: Swirl) {
        let chain = Chain(chainType: .vertical)
        let swirlArray = removeMatchSet.map({ Array($0.swirls) }).reduce([], +)
        if swirl.row - 1 > -1 &&
            swirls[swirl.column, swirl.row - 1]?.swirlType == swirl.swirlType &&
            !swirlArray.contains(swirls[swirl.column, swirl.row - 1]!) {
            chain.add(swirl: swirls[swirl.column, swirl.row - 1]!)
            removeMatchSet.insert(chain)
            verticalMatchDownward(swirl: swirls[swirl.column , swirl.row  - 1]!)
            horizontalMatchForward(swirl: swirls[swirl.column, swirl.row - 1]!)
            horizontalMatchBackward(swirl: swirls[swirl.column, swirl.row - 1]!)
        }
    }
    
    func horizontalMatchForward(swirl: Swirl) {
        let chain = Chain(chainType: .horizontal)
        let swirlArray = removeMatchSet.map({ Array($0.swirls) }).reduce([], +)
        if swirl.column + 1 < NumColumns &&
            swirls[swirl.column + 1, swirl.row]?.swirlType == swirl.swirlType &&
            !swirlArray.contains(swirls[swirl.column + 1, swirl.row]!) {
            chain.add(swirl: swirls[swirl.column + 1, swirl.row]!)
            removeMatchSet.insert(chain)
            horizontalMatchForward(swirl: swirls[swirl.column + 1, swirl.row]!)
            verticalMatchUpward(swirl: swirls[swirl.column + 1, swirl.row]!)
            verticalMatchDownward(swirl: swirls[swirl.column + 1, swirl.row]!)
        }
    }
    
    func horizontalMatchBackward(swirl: Swirl) {
        let chain = Chain(chainType: .horizontal)
        let swirlArray = removeMatchSet.map({ Array($0.swirls) }).reduce([], +)
        if swirl.column - 1  > -1 &&
            swirls[swirl.column - 1, swirl.row]?.swirlType == swirl.swirlType &&
            !swirlArray.contains(swirls[swirl.column - 1, swirl.row]!){

            chain.add(swirl: swirls[swirl.column - 1, swirl.row]!)
            removeMatchSet.insert(chain)
            horizontalMatchBackward(swirl: swirls[swirl.column - 1, swirl.row]!)
            verticalMatchDownward(swirl: swirls[swirl.column - 1, swirl.row]!)
            verticalMatchUpward(swirl: swirls[swirl.column - 1, swirl.row]!)
        }
    }
    
    func detectMatch(swirl: Swirl) -> Set<Chain>  {
        let chain = Chain(chainType: .vertical)
        verticalMatchUpward(swirl: swirl)
        verticalMatchDownward(swirl: swirl)
        horizontalMatchForward(swirl: swirl)
        horizontalMatchBackward(swirl: swirl)
        chain.add(swirl: swirl)
        removeMatchSet.insert(chain)
        return removeMatchSet
    }
    
    // Detects whether there are any chains of 3 or more swirls, and removes
    // them from the level.
    // Returns a set containing Chain objects, which describe the swirls
    // that were removed.
    func removeMatches() -> Set<Chain> {
        //        let horizontalChains = detectMatch(swirl: swirl)
        // let verticalChains = detectVerticalMatches()
        
        // Note: to detect more advanced patterns such as an L shape, you can see
        // whether a swirl is in both the horizontal & vertical chains sets and
        // whether it is the first or last in the array (at a corner). Then you
        // create a new Chain object with the new type and remove the other two.
       removeSwirls(removeMatchSet)
        //  removeSwirls(verticalChains)
        
        return removeMatchSet
    }
    
    fileprivate func removeSwirls(_ chains: Set<Chain>) {
        for chain in chains {
            for swirl in chain.swirls {
                swirls[swirl.column, swirl.row] = nil
            }
        }
    }
    
    
    // MARK: Detecting Holes
    
    // Detects where there are holes and shifts any swirls down to fill up those
    // holes. In effect, this "bubbles" the holes up to the top of the column.
    // Returns an array that contains a sub-array for each column that had holes,
    // with the swirl objects that have shifted. Those swirls are already
    // moved to their new position. The objects are ordered from the bottom up.
    func fillHoles() -> [[Swirl]] {
        var columns = [[Swirl]]()       // you can also write this Array<Array<Swirl>>
        
        // Loop through the rows, from bottom to top. It's handy that our row 0 is
        // at the bottom already. Because we're scanning from bottom to top, this
        // automatically causes an entire stack to fall down to fill up a hole.
        // We scan one column at a time.
        
        for column in 0..<NumColumns {
            var array = [Swirl]()
            for row in 0..<NumRows {
                
                // If there is a tile at this position but no swirl, then there's a hole.
                if tiles[column, row] != nil && swirls[column, row] == nil {
                    
                    // Scan upward to find a swirl.
                    for lookup in (row + 1)..<NumRows {
                        if let swirl = swirls[column, lookup] {
                            // Swap that swirl with the hole.
                            swirls[column, lookup] = nil
                            swirls[column, row] = swirl
                            swirl.row = row
                            
                            // For each column, we return an array with the swirls that have
                            // fallen down. swirls that are lower on the screen are first in
                            // the array. We need an array to keep this order intact, so the
                            // animation code can apply the correct kind of delay.
                            array.append(swirl)
                            
                            // Don't need to scan up any further.
                            break
                        }
                    }
                }
            }
            
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }
 
    
    func fillRowsHorizontal() -> [[Swirl]] {
        var horizontalHoles = [[Swirl]]()
        for column in 0..<NumColumns {
            var array = [Swirl]()
            if tiles[column, 0] != nil && swirls[column, 0] == nil {
                for lookup in (column + 1)..<NumColumns {
                    if swirls[lookup, 0] != nil {
                        for row in 0..<NumRows {
                            if let swirl = swirls[lookup, row] {
                                swirls[column, row] = swirl
                                swirl.column = column
                                swirls[lookup, row] = nil
                                array.append(swirl)
                            }
                        }
                        break
                    }
                }
                if !array.isEmpty {
                    horizontalHoles.append(array)
                }
            }
        }
        return horizontalHoles
    }
    
}

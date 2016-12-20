//
//  Array2D.swift
//  SwirlGame
//
//  Created by Techjini on 12/12/16.
//  Copyright © 2016 Techjini. All rights reserved.
//

struct Array2D<T> {
  
  let columns: Int
  let rows: Int
  fileprivate var array: Array<T?>
  
  init(columns: Int, rows: Int) {
    self.columns = columns
    self.rows = rows
    array = Array<T?>(repeating: nil, count: rows*columns)
  }
  
  subscript(column: Int, row: Int) -> T? {
    get {
      return array[row*columns + column]
    }
    set {
      array[row*columns + column] = newValue
    }
  }
  
}

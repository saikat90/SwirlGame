//
//  Chain.swift
//  SwirlGame
//
//  Created by Techjini on 12/12/16.
//  Copyright © 2016 Techjini. All rights reserved.
//

class Chain: Hashable, CustomStringConvertible {
  // The Cookies that are part of this chain.
  var swirls = [Swirl]()
  
  enum ChainType: CustomStringConvertible {
    case horizontal
    case vertical
    
    // Note: add any other shapes you want to detect to this list.
    //case ChainTypeLShape
    //case ChainTypeTShape
    
    var description: String {
      switch self {
      case .horizontal: return "Horizontal"
      case .vertical: return "Vertical"
      }
    }
  }
  
  // Whether this chain is horizontal or vertical.
  var chainType: ChainType
  
  
  init(chainType: ChainType) {
    self.chainType = chainType
  }
  
  func add(swirl: Swirl) {
    swirls.append(swirl)
  }
  
  func firstCookie() -> Swirl {
    return swirls[0]
  }
  
  func lastCookie() -> Swirl {
    return swirls[swirls.count - 1]
  }
  
  var length: Int {
    return swirls.count
  }
  
  var description: String {
    return "type:\(chainType) cookies:\(swirls)"
  }
  
  var hashValue: Int {
    return swirls.reduce (0) { $0.hashValue ^ $1.hashValue }
  }
  
}

func ==(lhs: Chain, rhs: Chain) -> Bool {
  return lhs.swirls == rhs.swirls
}

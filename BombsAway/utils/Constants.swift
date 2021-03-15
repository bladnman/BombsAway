//
//  Constants.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/8/21.
//

import CoreGraphics
import Foundation

typealias C = Constants
typealias C_OBJ_NAME = Constants.Objects.Names
typealias C_PHY = Constants.Physics
typealias C_PHY_CAT = Constants.Physics.Categories
typealias C_ZPOS = Constants.ZPositions
typealias C_ANIS = Constants.Anis
typealias C_MOVE = Constants.Movement
typealias C_CELL_MODE = Constants.Cell.Modes

struct Constants {
  
  struct Objects {
    enum Names {
      static let player = "player"
      static let boardNode = "boardNode"
      static let worldNode = "worldNode"
      static let ship = "ship"
      static let worldFloor = "worldFloor"
      static let cellFloor = "cellFloor"
      static let boardCell = "boardCell"
      static let label = "label"
      static let origin = "origin"
      static let pivot = "pivot"
      static let hitcoin = "hitcoin"
      static let attackBoard = "attackBoard"
      static let defendBoard = "defendBoard"
    }
  }
  struct Cell {
    enum Modes {
      case none
      case move
      case highlight
    }
  }
  
  struct Physics {
    enum Categories {
      static let none: UInt32 = 0
      static let splop: UInt32 = 0x1
      static let frame: UInt32 = 0x1 << 1
      static let all = UInt32.max
    }
  }
  enum ZPositions {
    // backgrounds
    static let farBG: CGFloat = 10
    static let closeBG: CGFloat = 11
  }
  struct Anis {
    struct Player {
      struct idle {
        static let atlasName = "playerIdleAtlas"
        static let frameKey = "idle_"
      }
    }
  }
  struct Movement {
    struct Player {
      static let perCellSec = 0.05
      static let perCellPauseSec = 0.01
    }
    struct BoardCell {
      struct SelectIndicator {
        static let fadeInSec = 0.01
        static let fadeOutSec = 0.9
      }
    }
  }
}

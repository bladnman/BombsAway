//
//  Constants.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/8/21.
//

import CoreGraphics
import Foundation
import UIKit

typealias C = Constants
typealias C_OBJ_NAME = Constants.Objects.Names
typealias C_PHY = Constants.Physics
typealias C_PHY_CAT = Constants.Physics.Categories
typealias C_ZPOS = Constants.ZPositions
typealias C_ANIS = Constants.Anis
typealias C_MOVE = Constants.Movement
typealias C_CELL_MODE = Constants.Cell.Modes
typealias C_COLOR = Constants.Colors
typealias C_BOARD = Constants.Board
typealias C_PLAYER = Constants.Player
typealias C_DBG = Constants.Debug

struct Constants {
  struct Debug {
    static let showHiddenShipFloors = false
  }
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
  struct Board {
    struct Size {
      static let columns = 10
      static let rows = 10
    }
    struct ProbabilityIndicator {
      static let radius = 3
    }
  }
  struct Player {
    static let startingHealth = 3
  }
  struct Movement {
    struct Player {
      static let initialStepsPerMove = 2
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
  struct Colors {
    static let blue = UIColor.fromHex("#22374a")
    static let yellowLight = UIColor.fromHex("#f6e58d")
    static let yellow = UIColor.fromHex("#f9ca24")
    static let orangeLight = UIColor.fromHex("#ffbe76")
    static let orange = UIColor.fromHex("#f0932b")
    static let redLight = UIColor.fromHex("#ff7979")
    static let red = UIColor.fromHex("#eb4d4b")
    static let greenLight = UIColor.fromHex("#badc58")
    static let green = UIColor.fromHex("#6ab04c")
    static let lightBlueLight = UIColor.fromHex("#7ed6df")
    static let lightBlue = UIColor.fromHex("#d4d7d8")
//    static let blueLight = UIColor.fromHex("#686de0")
//    static let blue = UIColor.fromHex("#4834d4")
  }
}

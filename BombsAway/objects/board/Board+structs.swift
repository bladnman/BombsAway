//
//  Board+tests.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/7/21.
//
import SceneKit
import UIKit

struct BoardSize {
  var columns: Int
  var rows: Int
}
extension BoardSize {
  var isZero: Bool { return columns == 0 && rows == 0 }
  init(_ sizeVector: SCNVector3) {
    self.columns = Int(sizeVector.x)
    self.rows = Int(sizeVector.z)
  }
  static var zero:BoardSize { return BoardSize(SCNVector3(0,0,0)) }
}

struct BoardRect {
  var firstGP: GridPoint
  var lastGP: GridPoint
  var columnRange: CountableClosedRange<Int> { return firstGP.column...lastGP.column }
  var rowRange: CountableClosedRange<Int> { return firstGP.row...lastGP.row }
  func contains(_ gp: GridPoint) -> Bool {
    return columnRange.contains(gp.column) && rowRange.contains(gp.row)
  }
}

struct BoardRange {
  var columnRange: CountableClosedRange<Int>
  var rowRange: CountableClosedRange<Int>
}

extension BoardRange {
  init(_ gp: GridPoint, _ size: BoardSize) {
    let endCol = gp.column + (size.columns > 0 ? size.columns - 1 : size.columns + 1)
    let endRow = gp.row + (size.rows > 0 ? size.rows - 1 : size.rows + 1)

    self.columnRange = rangeFrom(gp.column, endCol)
    self.rowRange = rangeFrom(gp.row, endRow)
  }
}

struct BoxFrame {
  var xMin: Float
  var xMax: Float
  var yMin: Float
  var yMax: Float
  var xDelta: Float { return xMax - xMin }
  var yDelta: Float { return yMax - yMin }
  var isHorizontal: Bool { return xMax - xMin > 1 }
  var isVertical: Bool { return yMax - yMin > 1 }
}
struct BoardDirection {
  let columns: Float
  let rows: Float
  
  var isRight: Bool { return columns > 1 }
  var isLeft: Bool { return columns < -1 }
  var isDown: Bool { return rows > 1 }
  var isUp: Bool { return rows < -1 }
  var isHorizontal: Bool { return isLeft || isRight }
  var isVertical: Bool { return isUp || isDown }
  var isZero: Bool { return columns == 0 && rows == 0 }
  
  init(_ size: BoardSize) {
    self.columns = Float(size.columns)
    self.rows = Float(size.rows)
  }
  
  static var zero:BoardDirection { return BoardDirection(BoardSize(columns: 0, rows: 0)) }
}

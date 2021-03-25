//
//  Board+structs.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/7/21.
//
import SceneKit
import UIKit
enum Direction {
  case n,e,s,w,ne,se,sw,nw
}
extension Board {
  
  // MARK: CELL GETTERS

  func cellListFor(_ boardRange: BoardRange) -> [BoardCell] {
    var cells = [BoardCell]()
    for c in boardRange.columnRange {
      for r in boardRange.rowRange {
        if let cell = cellFor(GridPoint(c, r)) {
          cells.append(cell)
        }
      }
    }
    return cells
  }
  func cellListFor(_ boardRect: BoardRect) -> [BoardCell] {
    var cells = [BoardCell]()
    for c in boardRect.firstGP.column...boardRect.lastGP.column {
      for r in boardRect.firstGP.row...boardRect.lastGP.row {
        if let cell = cellFor(GridPoint(c, r)) {
          cells.append(cell)
        }
      }
    }
    return cells
  }
  func cellListFor(_ centerGP: GridPoint, radius: Int = 0) -> [BoardCell] {
    return cellListFor(BoardRange(columnRange: centerGP.column-radius...centerGP.column+radius, rowRange: centerGP.row-radius...centerGP.row+radius))
  }
  func cellListForRing(_ centerGP: GridPoint, radius: Int) -> [BoardCell] {
    let colMin = max(1, centerGP.column - radius)
    let colMax = min(columns, centerGP.column + radius)
    let rowMin = max(1, centerGP.row - radius)
    let rowMax = min(rows, centerGP.row + radius)
    
    var outCellDict = [String: BoardCell]()
    
    // top (only if not cut off)
    if rowMin == centerGP.row - radius {
      for c in colMin...colMax {
        if let cell = cellFor(c, rowMin) {
          outCellDict[cell.gridPoint.toString()] = cell
        }
      }
    }
    // bottom (only if not cut off)
    if rowMax == centerGP.row + radius {
      for c in colMin...colMax {
        if let cell = cellFor(c, rowMax) {
          outCellDict[cell.gridPoint.toString()] = cell
        }
      }
    }
    
    // left (only if not cut off)
    if colMin == centerGP.column - radius {
      for r in rowMin...rowMax {
        if let cell = cellFor(colMin, r) {
          outCellDict[cell.gridPoint.toString()] = cell
        }
      }
    }
    // right (only if not cut off)
    if colMax == centerGP.column + radius {
      for r in rowMin...rowMax {
        if let cell = cellFor(colMax, r) {
          outCellDict[cell.gridPoint.toString()] = cell
        }
      }
    }
    
    return [BoardCell](outCellDict.values)
  }
  func cellListForStraights(_ centerGP: GridPoint, radius: Int) -> [BoardCell] {
    let colMin = max(1, centerGP.column - radius)
    let colMax = min(columns, centerGP.column + radius)
    let rowMin = max(1, centerGP.row - radius)
    let rowMax = min(rows, centerGP.row + radius)
    return cellListForStraights(centerGP, columnRange: colMin...colMax, rowRange: rowMin...rowMax)
  }
  func cellListForStraights(_ centerGP: GridPoint, columnRange: ClosedRange<Int>, rowRange: ClosedRange<Int>) -> [BoardCell] {
    var outCellList = [BoardCell]()
    
    // horizontal
    for c in columnRange {
      if let cell = cellFor(c, centerGP.row) {
        outCellList.append(cell)
      }
    }
    // vertical
    for r in rowRange {
      if let cell = cellFor(centerGP.column, r) {
        outCellList.append(cell)
      }
    }
    
    return outCellList
  }
  func cellListForDiagonals(_ centerGP: GridPoint, columnRange: ClosedRange<Int>) -> [BoardCell] {
    var outCellList = [BoardCell]()
    
    for c in columnRange {
      let deltaFromCenter = c - centerGP.column
      
      if let cell = cellFor(c, centerGP.row + deltaFromCenter) {
        outCellList.append(cell)
      }
      if let cell = cellFor(c, centerGP.row - deltaFromCenter) {
        outCellList.append(cell)
      }
    }
    
    return outCellList
  }
  func cellListForDiagonals(_ centerGP: GridPoint, radius: Int) -> [BoardCell] {
    let colMin = max(1, centerGP.column - radius)
    let colMax = min(columns, centerGP.column + radius)
    var outCellList = [BoardCell]()
    
    for c in colMin...colMax {
      let deltaFromCenter = c - centerGP.column
      
      if let cell = cellFor(c, centerGP.row + deltaFromCenter) {
        outCellList.append(cell)
      }
      if let cell = cellFor(c, centerGP.row - deltaFromCenter) {
        outCellList.append(cell)
      }
    }
    
    return outCellList
  }
  func cellListForDiagonals(startGP: GridPoint, endGP: GridPoint) -> [BoardCell] {
    if !isValid(startGP) || !isValid(endGP) { return [] }
    if !startGP.isDiagonalTo(endGP) { return [] }
    
    // same gp
    if startGP == endGP {
      return [cellFor(startGP)!]
    }
    
    var outCellList = [BoardCell]()
    if let cell = cellFor(attackShip.gridPoint.column, attackShip.gridPoint.row) {
      outCellList.append(cell)
    }
    
    let columnIncreases = (endGP.column - startGP.column) > 0
    let rowIncreases = (endGP.row - startGP.row) > 0
    let steps = abs(endGP.column - startGP.column)
    for step in 1...steps {
      let c = columnIncreases ? startGP.column + step : startGP.column - step
      let r = rowIncreases ? startGP.row + step : startGP.row - step
      if let cell = cellFor(c, r) {
        outCellList.append(cell)
      }
    }
    return outCellList
  }
  func cellListForStraights(startGP: GridPoint, endGP: GridPoint) -> [BoardCell] {
    if !isValid(startGP) || !isValid(endGP) { return [] }
    if !startGP.isStraightTo(endGP) { return [] }
    
    // same gp
    if startGP == endGP {
      return [cellFor(startGP)!]
    }
    
    var outCellList = [BoardCell]()
    if let cell = cellFor(attackShip.gridPoint.column, attackShip.gridPoint.row) {
      outCellList.append(cell)
    }
    
    let isHorizontal = startGP.row == endGP.row
    
    if isHorizontal {
      let increases = (endGP.column - startGP.column) > 0
      let steps = abs(endGP.column - startGP.column)
      for step in 1...steps {
        let c = increases ? startGP.column + step : startGP.column - step
        if let cell = cellFor(c, startGP.row) {
          outCellList.append(cell)
        }
      }
    } else {
      let increases = (endGP.row - startGP.row) > 0
      let steps = abs(endGP.row - startGP.row)
      for step in 1...steps {
        let r = increases ? startGP.row + step : startGP.row - step
        if let cell = cellFor(startGP.column, r) {
          outCellList.append(cell)
        }
      }
    }

    return outCellList
  }
  func cellListForJourney(startGP: GridPoint, endGP: GridPoint) -> [BoardCell] {
    let possibleDiagonals = cellListForDiagonals(startGP: startGP, endGP: endGP)
    let possibleStraights = cellListForStraights(startGP: startGP, endGP: endGP)
    return possibleDiagonals + possibleStraights
  }
  func cellListForDirection(_ startGP: GridPoint, radius: Int, direction: Direction, includeStartGP: Bool = true) -> [BoardCell] {
    
    var startColumn = startGP.column
    var startRow = startGP.row
    
    if !includeStartGP {
      switch direction {
        case .n: startRow -= 1
        case .e: startColumn += 1
        case .s: startRow += 1
        case .w: startColumn -= 1
        case .ne:
          startRow -= 1
          startColumn += 1
        case .se:
          startRow += 1
          startColumn += 1
        case .sw:
          startRow += 1
          startColumn -= 1
        case .nw:
          startRow -= 1
          startColumn -= 1
        }
    }
    
    let actualStartGP = GridPoint(startColumn, startRow)
    let actualRadius = includeStartGP ? radius - 1 : radius - 2
    
    // nothing to do - bail
    if actualRadius < 0 {
      return [BoardCell]()
    }
    
    var colMin = actualStartGP.column - actualRadius
    var colMax = actualStartGP.column + actualRadius
    var rowMin = actualStartGP.row - actualRadius
    var rowMax = actualStartGP.row + actualRadius

    
    // clamp columns
    if !isLeft(direction) {
      colMin = actualStartGP.column
    }
    if !isRight(direction) {
      colMax = actualStartGP.column
    }
    // clamp rows
    if !isUp(direction) {
      rowMin = actualStartGP.row
    }
    if !isDown(direction) {
      rowMax = actualStartGP.row
    }
    
    switch direction {
      case .n,.e,.s,.w:
        return cellListForStraights(actualStartGP, columnRange: colMin...colMax, rowRange: rowMin...rowMax)
      case .ne,.se,.sw,.nw:
        var outCellList = [BoardCell]()
        for c in colMin...colMax {
          let deltaFromCenter = c - actualStartGP.column
          
          if direction == .nw || direction == .se {
            if let cell = cellFor(c, actualStartGP.row + deltaFromCenter) {
              outCellList.append(cell)
            }
          }
          if direction == .sw || direction == .ne {
            let gp = GridPoint(c, actualStartGP.row - deltaFromCenter)
            if let cell = cellFor(gp) {
              outCellList.append(cell)
            }
          }
        }
        return outCellList
    }
    
  }
  
  // MARK: CELL CONVINIENCE
  func cellFor(_ gp: GridPoint) -> BoardCell? {
    if let cell = cellFor(gp.column, gp.row) {
      return cell
    }
    return nil
  }
  func cellFor(_ column: Int, _ row: Int) -> BoardCell? {
    if let cell = cellList[GridPoint(column, row).toString()] {
      return cell
    }
    return nil
  }
  func setCell(_ column: Int, _ row: Int, node: BoardCell) {
    cellList[GridPoint(column, row).toString()] = node
  }
  
  // MARK: OTHERS
  func boxForRange(_ boardRange: BoardRange) -> BoxFrame {
    return BoxFrame(
      xMin: Float(boardRange.columnRange.min() ?? 0) - 0.5,
      xMax: Float(boardRange.columnRange.max() ?? 0) + 0.5,
      yMin: Float(boardRange.rowRange.min() ?? 0) - 0.5,
      yMax: Float(boardRange.rowRange.max() ?? 0) + 0.5)
  }
  func getEndPoint(_ startGP: GridPoint, _ sizeGP: GridPoint) -> GridPoint {
    let nearEndGP = startGP + sizeGP

    // adjust for the start point
    return GridPoint(
      nearEndGP.column > startGP.column ? nearEndGP.column - 1 : nearEndGP.column + 1,
      nearEndGP.row > startGP.row ? nearEndGP.row - 1 : nearEndGP.row + 1)
  }
  func isValid(_ gp: GridPoint) -> Bool {
    return (1...columns ~= gp.column) && (1...rows ~= gp.row)
  }
  func isValidMove(_ gp: GridPoint) -> Bool {
    return isValid(gp) &&
      (attackShip.gridPoint.isDiagonalTo(gp) || attackShip.gridPoint.isStraightTo(gp))
  }
  func isClearForShipPlacement(_ gp: GridPoint) -> Bool {
    return cellFor(gp)?.isClearForShipPlacement ?? false
  }
  func isClearForShipPlacement(_ cellList: [BoardCell]) -> Bool {
    if cellList.contains(where: { !$0.isClearForShipPlacement }) {
      return false
    }
    return true
  }
  func isWithinBoard(_ boardRect: BoardRect) -> Bool {
    return isWithinBoard(boardRect.firstGP) && isWithinBoard(boardRect.lastGP)
  }
  func isWithinBoard(_ gpList: [GridPoint]) -> Bool {
    if gpList.contains(where: { !isWithinBoard($0) }) {
      return false
    }
    return true
  }
  func isWithinBoard(_ gp: GridPoint) -> Bool {
    return gp.column > 0 &&
           gp.column <= columns &&
           gp.row > 0 &&
           gp.row <= rows
  }
  
  func positionForGridPoint(_ gridPoint: GridPoint) -> SCNVector3 {
    return positionForGridPoint(gridPoint, andHeight: 0.0)
  }
  func positionForGridPoint(_ gridPoint: GridPoint, andHeight: Float) -> SCNVector3 {
    return SCNVector3(Float(gridPoint.column), andHeight, Float(gridPoint.row * zMod))
  }
}

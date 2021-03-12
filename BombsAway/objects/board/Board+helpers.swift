//
//  Board+structs.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/7/21.
//
import SceneKit
import UIKit
extension Board {
  
  // MARK: CELL GETTERS

  func cellListFor(_ boardRange: BoardRange) -> [BoardCell] {
    var cellList = [BoardCell]()
    for c in boardRange.columnRange {
      for r in boardRange.rowRange {
        if let cell = cellFor(GridPoint(c, r)) {
          cellList.append(cell)
        }
      }
    }
    return cellList
  }
  func cellListFor(_ boardRect: BoardRect) -> [BoardCell] {
    var cellList = [BoardCell]()
    for c in boardRect.firstGP.column...boardRect.lastGP.column {
      for r in boardRect.firstGP.row...boardRect.lastGP.row {
        if let cell = cellFor(GridPoint(c, r)) {
          cellList.append(cell)
        }
      }
    }
    return cellList
  }
  func cellListFor(_ centerGP: GridPoint, radius: Int = 0) -> [BoardCell] {
    return cellListFor(BoardRange(columnRange: centerGP.column...centerGP.column, rowRange: centerGP.row...centerGP.row))
  }
  func cellListForRing(_ centerGP: GridPoint, radius: Int) -> [BoardCell] {
    let colMin = max(1, centerGP.column - radius)
    let colMax = min(columns, centerGP.column + radius)
    let rowMin = max(1, centerGP.row - radius)
    let rowMax = min(rows, centerGP.row + radius)
    
    var outCellList = [BoardCell]()
    
    // top (only if not cut off)
    if rowMin == centerGP.row - radius {
      for c in colMin...colMax {
        if let cell = cellFor(c, rowMin) {
          outCellList.append(cell)
        }
      }
    }
    // bottom (only if not cut off)
    if rowMax == centerGP.row + radius {
      for c in colMin...colMax {
        if let cell = cellFor(c, rowMax) {
          outCellList.append(cell)
        }
      }
    }
    
    // left (only if not cut off)
    if colMin == centerGP.column - radius {
      for r in rowMin...rowMax {
        if let cell = cellFor(colMin, r) {
          outCellList.append(cell)
        }
      }
    }
    // right (only if not cut off)
    if colMax == centerGP.column + radius {
      for r in rowMin...rowMax {
        if let cell = cellFor(colMax, r) {
          outCellList.append(cell)
        }
      }
    }
    
    return outCellList
  }
  func cellListForStraights(_ centerGP: GridPoint, radius: Int) -> [BoardCell] {
    let colMin = max(1, centerGP.column - radius)
    let colMax = min(columns, centerGP.column + radius)
    let rowMin = max(1, centerGP.row - radius)
    let rowMax = min(rows, centerGP.row + radius)
    
    var outCellList = [BoardCell]()
    
    // horizontal
    for c in colMin...colMax {
      if let cell = cellFor(c, centerGP.row) {
        outCellList.append(cell)
      }
    }
    // vertical
    for r in rowMin...rowMax {
      if let cell = cellFor(centerGP.column, r) {
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
  func cellListForDiagonalsBetween(startGP: GridPoint, endGP: GridPoint) -> [BoardCell] {
    if !startGP.isDiagonalTo(endGP) {
      return []
    }
    
    var outCellList = [BoardCell]()
    if let cell = cellFor(player.gridPoint.column, player.gridPoint.row) {
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
  func cellListForStraightsBetween(startGP: GridPoint, endGP: GridPoint) -> [BoardCell] {
    if !startGP.isStraightTo(endGP) {
      return []
    }
    
    var outCellList = [BoardCell]()
    if let cell = cellFor(player.gridPoint.column, player.gridPoint.row) {
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
      (player.gridPoint.isDiagonalTo(gp) || player.gridPoint.isStraightTo(gp))
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

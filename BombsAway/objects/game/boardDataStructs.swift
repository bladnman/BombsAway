//
//  boardDataStructs.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/27/21.
//

import Foundation
class ShotData {
  let gridPoint: GridPoint
  init(gridPoint: GridPoint) {
    self.gridPoint = gridPoint
  }
}
class ProbeData {
  let gridPoint: GridPoint
  let liveForTurns: Int  // -1 mean live forever
  init(gridPoint: GridPoint, liveForTurns: Int = -1) {
    self.gridPoint = gridPoint
    self.liveForTurns = liveForTurns
  }
}
class CollectibleData {
  let gridPoint: GridPoint
  init(gridPoint: GridPoint) {
    self.gridPoint = gridPoint
  }
//  let collectibleType: CollectibleType
//  init(gridPoint: GridPoint, collectibleType: CollectibleType) {
//    self.gridPoint = gridPoint
//    self.collectibleType = collectibleType
//  }
}
class ShipData {
  let startGridPoint: GridPoint
  let boardSize: BoardSize
  let gridPoints: [GridPoint]
  
  var boardRange: BoardRange { BoardRange(startGridPoint, boardSize) }
  
  init(startGridPoint: GridPoint, boardSize: BoardSize) {
    self.startGridPoint = startGridPoint
    self.boardSize = boardSize
    self.gridPoints = gridPointsFor(boardRange: BoardRange(startGridPoint, boardSize))
  }
  func contains(_ gp: GridPoint) -> Bool {
    return boardRange.columnRange.contains(gp.column) && boardRange.rowRange.contains(gp.row)
  }
  func containsAny(_ gridPoints:[GridPoint]) -> Bool {
    for gridPoint in gridPoints {
      if contains(gridPoint) {
        return true
      }
    }
    return false
  }
  
}
class AttackerData {
  let playerId: Int
  var gridPoint: GridPoint
  init(playerId: Int, gridPoint: GridPoint = GridPoint.zero) {
    self.playerId = playerId
    self.gridPoint = gridPoint
  }
}

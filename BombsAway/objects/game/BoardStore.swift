//
//  BoardStore.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/27/21.
//

import Foundation
class BoardStore: CustomStringConvertible {
  var boardSize = BoardSize(columns: C_BOARD.Size.columns, rows: C_BOARD.Size.rows)
  var shots = [ShotData]()
  var probes = [ProbeData]()
  var collectibles = [CollectibleData]()
  var ships = [ShipData]()
  var spawnPoint = GridPoint.zero
  var spawnRect = BoardRect.zero
  let playerId: Int
  
  // attached once created
  var boardRef: Board?
  
  init(playerId: Int) {
    self.playerId = playerId
  }
  
  func doesGridPointContainShip(_ gridPoint: GridPoint) -> Bool {
    return getShipAtGridpoint(gridPoint) != nil
  }
  func getShipAtGridpoint(_ gridPoint: GridPoint) -> ShipData? {
    for ship in ships {
      if ship.gridPoints.contains(where: { $0 == gridPoint }) {
        return ship
      }
    }
    return nil
  }
  func isShipSunk(_ ship: ShipData?) -> Bool {
    if ship == nil {
      return false
    }
    
    for shipGP in ship!.gridPoints {
      let found = shots.contains(where: { $0.gridPoint == shipGP })
      if !found {
        return false
      }
    }
    return true
  }
  
  // MARK: MUST DO ATTACKER ARRAY
}

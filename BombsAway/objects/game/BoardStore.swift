//
//  BoardStore.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/27/21.
//

import Foundation
class BoardStore {
  var boardSize = BoardSize(columns: C_BOARD.Size.columns, rows: C_BOARD.Size.rows)
  var shots = [ShotData]()
  var probes = [ProbeData]()
  var collectibles = [CollectibleData]()
  var ships = [ShipData]()
  var spawnPoint = GridPoint.zero
  var spawnRect = BoardRect.zero
  
  // MARK: MUST DO ATTACKER ARRAY
}

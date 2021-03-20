//
//  Board+boardCell.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/15/21.
//

import UIKit

extension Board: BoardCellDelegate {
  func bcellGetSurroundingProbeCount(_ gp: GridPoint) -> Int {
    
    var probeCount = 0;
    let ringCells = cellListForRing(gp, radius: 1)
    ringCells.forEach { cell in
      if cell.hasProbe { probeCount += 1 }
      if cell.gridPoint == player.gridPoint { probeCount += 1 }
    }
    return probeCount
  }
}

//
//  Board+boardCell.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/15/21.
//

import UIKit

extension Board: BoardCellDelegate {
  func bcellGetSurroundingThreats(_ gp: GridPoint) -> ThreatDirections {
    let directions = [
      Direction.n,Direction.e,Direction.s,Direction.w,
      Direction.ne,Direction.se,Direction.sw,Direction.nw,
    ]
    
    let threats = ThreatDirections()
    for direction in directions {
      let surroundingCells = cellListForDirection(gp, radius: C_BOARD.ProbabilityIndicator.radius, direction: direction, includeStartGP: false)
      
      threats.setForDirection(direction, surroundingCells.contains(where: { $0.hasSolidShip }))
      if let ownCell = cellFor(gp) {
        threats.center = ownCell.hasSolidShip
      }
    }
    
//    let colors = [UIColor.purple, UIColor.green, UIColor.systemPink, UIColor.orange, UIColor.black, UIColor.blue];
//    let thisColor = colors.randomElement()
//    print("[M@] -------- cells returned")
//    for cell in cells {
//      if let mat = cell.floor.geometry?.firstMaterial {
//        mat.diffuse.contents = thisColor
//        print("[M@] [\(cell.gridPoint.toString())] being colored")
//      }
//    }

    
    return threats
  }
  
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

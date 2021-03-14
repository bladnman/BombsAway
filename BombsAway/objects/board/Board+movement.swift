//
//  Board+tests.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/7/21.
//
import SceneKit
import UIKit
extension Board {
  func movePlayerShipTo(_ gp: GridPoint, force: Bool = false) {
    guard force || isValidMove(gp) else {
      return
    }
    
    var finalGP = gp
    
    if !force {
      // must find ships in the way
      let diagonals = cellListForDiagonalsBetween(startGP: player.gridPoint, endGP: gp)
      let straights = cellListForStraightsBetween(startGP: player.gridPoint, endGP: gp)
      let cellSteps = diagonals + straights
      
      // no steps
      if cellSteps.isEmpty {
        return
      }
      
      var finalCellStop = cellSteps.last
      if let i = cellSteps.firstIndex(where: { $0.hasSolidShip }) {
        
        // YOU HIT A SHIP
        let shipCell = cellSteps[i]
        if let targetShip = shipCell.targetShipRef {
          if targetShip.hitAt(shipCell.gridPoint) {
            if targetShip.isSunk {
              print("[M@] DUDE! YOU SUNK MY BATTLESHIP! \(String(describing: shipCell.gridPoint))")
            } else {
              print("[M@] we hit! \(String(describing: shipCell.gridPoint))")
            }
          }
        }
        finalCellStop = cellSteps[i-1]
      }
      
      if finalCellStop == nil {
        return
      }
      
      finalGP = finalCellStop!.gridPoint
    }

    
    moveToGridPoint(player, finalGP)
  }
}

//
//  Board+tests.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/7/21.
//
import SceneKit
import UIKit
extension Board {
  func stepPlayerShipTo(_ gp: GridPoint) {
    // invalid move - bail
    guard isValidMove(gp) else { return }
    
    var stepCellList = cellListForJourney(startGP: player.gridPoint, endGP: gp)
    
    // first cell is where the playerShip is now
    stepCellList.removeFirst()
    
    if let stepCell = stepCellList.first {
      // HIT SHIP ! !  - no move
      if stepCell.hasSolidShip {
        stepCell.targetShipRef?.hitAt(stepCell.gridPoint)
      }
      
      // just move
      else {
        if let nextStepGP = stepCell.gridPoint {
          let moveAction = SCNAction.move(to: positionForGridPoint(nextStepGP), duration: C_MOVE.Player.perCellSec)
          let pauseAction = SCNAction.wait(duration: C_MOVE.Player.perCellPauseSec)
          
          player.runAction(SCNAction.sequence([moveAction, pauseAction])) {
            self.drawAvailableZone()
            
            // not there yet - keep steppin'!
            if nextStepGP != gp {
              DispatchQueue.main.async {
                self.stepPlayerShipTo(gp)
              }
            }
          }
        }
      }
    }
  }
}

//
//  Board+tests.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/7/21.
//
import SceneKit
import UIKit
extension Board {
  func stepAttackShipTo(_ gp: GridPoint) {
    // invalid move - bail
    guard isValidMove(gp) else { return }
    
    var stepCellList = cellListForJourney(startGP: attackShip.gridPoint, endGP: gp)
    
    // first cell is where the attackShip is now
    stepCellList.removeFirst()
    
    if let stepCell = stepCellList.first {
      // MARK: HIT SHIP during move
      if stepCell.hasSolidShip {
        stepCell.attackCell()
        attackShip.takeAHit()
        delegate.boardSubstantialChage(board: self)
      }
      
      // keep moving
      else {
        if let nextStepGP = stepCell.gridPoint {
          let moveAction = SCNAction.move(to: positionForGridPoint(nextStepGP), duration: C_MOVE.Player.perCellSec)
          let pauseAction = SCNAction.wait(duration: C_MOVE.Player.perCellPauseSec)
          
          attackShip.runAction(SCNAction.sequence([moveAction, pauseAction])) {
            self.update()
            
            // not there yet - keep steppin'!
            if nextStepGP != gp {
              DispatchQueue.main.async {
                self.stepAttackShipTo(gp)
              }
            }
          }
        }
      }
    }
  }
  func sendProbeTo(_ gp: GridPoint) {
    if let cell = cellFor(gp) {
      cell.hasProbe = true
    }
  }
  func sendShotTo(_ gp: GridPoint) {
    if let cell = cellFor(gp) {
      cell.attackCell()
    }
  }
}

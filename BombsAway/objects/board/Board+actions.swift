//
//  Board+tests.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/7/21.
//
import SceneKit
import UIKit
extension Board {
  func doActionComplete(gameAction: GameAction) {
    delegate.boardActionComplete(gameAction: gameAction, board: self)
  }
  func stepAttackShipTo(_ gp: GridPoint, gameAction: GameAction) {
    // invalid move - bail
    guard isValidMove(gp) else { return }
    
    var stepCellList = cellListForJourney(startGP: attackShip.gridPoint, endGP: gp)
    
    // first cell is where the attackShip is now
    stepCellList.removeFirst()
    
    if let stepCell = stepCellList.first {
      // MARK: HIT SHIP during move (lose health)
      if stepCell.hasSolidShip {
        attackGridPoint(stepCell.gridPoint)
        let attackingPlayerStore = gameStore.playerStoreForId(gameAction.actionOwnerId)
        attackingPlayerStore?.hitPoints -= 1
        
        doActionComplete(gameAction: gameAction)
      }
      
      // keep moving
      else {
        if let nextStepGP = stepCell.gridPoint {
          let moveAction = SCNAction.move(to: positionForGridPoint(nextStepGP), duration: C_MOVE.Player.perCellSec)
          attackShip.runAction(moveAction) {
            self.attackShip.playerStore.gridPoint = nextStepGP
            self.update()
            
            // not there yet - keep steppin'!
            if nextStepGP != gp {
              DispatchQueue.main.async {
                self.stepAttackShipTo(gp, gameAction: gameAction)
              }
            }
            
            // action complete
            else {
              self.doActionComplete(gameAction: gameAction)
            }
          }
        }
      }
    }
  }
  func sendProbeTo(_ gp: GridPoint, gameAction: GameAction) {
    boardStore.probes.append(ProbeData(gridPoint: gp))
    if let cell = cellFor(gp) {
      cell.update()
    }
    doActionComplete(gameAction: gameAction)
  }
  func sendShotTo(_ gp: GridPoint, gameAction: GameAction) {
    attackGridPoint(gp)
    if let cell = cellFor(gp) {
//      cell.update()
      cell.updateShotIndicator()
    }
    doActionComplete(gameAction: gameAction)
  }
  func attackGridPoint(_ gp: GridPoint) {
    boardStore.shots.append(ShotData(gridPoint: gp))
    var gridPointsToUpdate = [gp]
    
    if let ship = boardStore.getShipAtGridpoint(gp) {
      if boardStore.isShipSunk(ship) {
        gridPointsToUpdate = ship.gridPoints
      }
    }

    // update cells
    for gridPoint in gridPointsToUpdate {
      if let cell = cellFor(gridPoint) {
        //      cell.update()
        cell.updateShotIndicator()
      }
    }
  }
}

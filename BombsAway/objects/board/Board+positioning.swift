//
//  Board+structs.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/7/21.
//
import SceneKit
import UIKit
extension Board {
  func positionShip(_ ship: TargetShip, _ startGP: GridPoint) {
    let boardRange = BoardRange(startGP, ship.boardSize)
    let positionFrame = boxForRange(boardRange)

    // CALCULATE PROPER X
    // add/remove 0.5 to make sure it covers grid cell
    var finalX: Float = 0.0
    if ship.direction.isVertical {
      finalX = positionFrame.xMax - 0.5
    } else {
      finalX = ship.direction.isLeft ? positionFrame.xMax : positionFrame.xMin
    }
    
    // CALCULATE PROPER Y
    // add/remove 0.5 to make sure it covers grid cell
    var finalY: Float = 0.0
    if ship.direction.isHorizontal {
      finalY = positionFrame.yMax - 0.5
    } else {
      finalY = ship.direction.isUp ? positionFrame.yMax : positionFrame.yMin
    }
    
    // position ship
    ship.position = SCNVector3(finalX, -1.0, finalY)
    
    // animate showing
    let delaySec = Double.random(in: 0.05...0.20)
    let delayAction = SCNAction.wait(duration: delaySec)
    let riseAction = SCNAction.move(by: SCNVector3(0.0, 1.0, 0.0), duration: 0.5)
    riseAction.timingMode = .easeOut
    let seqAction = SCNAction.sequence([delayAction, riseAction])
    ship.runAction(seqAction)
    
    // add ship to board
    if type == .defense {
      ship.geometry?.firstMaterial?.transparency = 0.7
      boardGeom.addChildNode(ship)
    }
    
    // UPDATE CELLS
    let shipCells = cellListFor(BoardRange(startGP, ship.boardSize))
    shipCells.forEach { cell in
      cell.isLabelVisible = false
      cell.targetShipRef = ship
    }
    
    // add awareness of these grid points to the ship
    // this makes the ship capable of answering which
    // part of it is hit
    ship.boardCells = shipCells
  }
}

//
//  Board+structs.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/7/21.
//
import SceneKit
import UIKit
extension Board {

  // MARK: POSITIONING
  func moveToGridPoint(_ node: SCNNode, _ gp: GridPoint) {
    let newToGrid = node.parent != boardGeom
    if newToGrid {
      boardGeom.addChildNode(node)
    }
    
    let newPosition = positionForGridPoint(gp)

    // JUST ADD NEW ITEMS
    if newToGrid {
      node.position = newPosition
    }

    // MOVE ACTION
    else {
      node.removeAllActions()

      let duration = 0.3
      let moveAction = SCNAction.move(to: newPosition, duration: duration)
      moveAction.timingMode = .easeInEaseOut
      
      node.runAction(moveAction, completionHandler: {
        node.removeAllActions()
        self.drawAvailableZone()
      })
    }
  }
  func positionShip(_ ship: ShipNode, _ startGP: GridPoint) {
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
//    boardGeom.addChildNode(ship)
    
    if !isOwn {
      ship.geometry?.firstMaterial?.transparency = 0.2
    }
    
    // UPDATE CELLS
    let shipCells = cellListFor(BoardRange(startGP, ship.boardSize))
    shipCells.forEach { cell in
      cell.isLabelVisible = false
      cell.shipRef = ship
    }
    
    // add awareness of these grid points to the ship
    // this makes the ship capable of answering which
    // part of it is hit
    ship.boardCells = shipCells
  }
}

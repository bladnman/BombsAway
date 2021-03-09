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
  func positionForGridPoint(_ gridPoint: GridPoint) -> SCNVector3 {
    return positionForGridPoint(gridPoint, andHeight: 0.0)
  }
  func positionForGridPoint(_ gridPoint: GridPoint, andHeight: Float) -> SCNVector3 {
    return SCNVector3(Float(gridPoint.column), andHeight, Float(gridPoint.row * zMod))
  }
  @discardableResult
  func placeAtGridPointIfClear(_ node: SCNNode, _ startGP: GridPoint) -> Bool {
    let shipSizeVector = rounded(measureToNodeSpace(node, to: boardGeom))
    let endGP = getEndPoint(startGP, GridPoint(shipSizeVector))

    // debugging purposes
//    showPlacementIndicatorsAt(startGP, endGP)
    
    // OFF BOARD - no place
    if startGP.column < 1 || startGP.column > columns ||
        startGP.row < 1 || startGP.row > rows ||
        endGP.column < 1 || endGP.column > columns ||
        endGP.row < 1 || endGP.row > rows {
      return false
    }
    
    let shipSize = BoardSize(shipSizeVector)
    let shipCells = cellListFor(BoardRange(startGP, shipSize))
    
    // SEE IF SPOTS ARE AVAILABLE
    // no ships, no spawn regions...
    if shipCells.contains(where: {
      $0.shipRef != nil || $0.isSpawnRegion
    }) {
      // found a ship
      return false
    }
    
    // SUCCESS
    positionShip(node, startGP, shipSize)

//    print("[M@] ----------------")
//    print("[M@] start cell    [\(String(describing: cellFor(startGP)))]")
//    print("[M@] startGP       [\(startGP)]")
//    print("[M@] endGP         [\(endGP)]")
//    print("[M@] ship size     [\(shipSize)]")
//    print("[M@] added ✅")

    return true
  }
  func moveToGridPoint(_ node: SCNNode, _ gp: GridPoint) {
    let newToGrid = node.parent != boardGeom
    if newToGrid {
      boardGeom.addChildNode(node)
    }

    let newPosition = positionForGridPoint(gp)

    // JUST ADD NEW ITEMS
    if newToGrid {
      // cells are 0-index, thus -1s
      node.position = newPosition
    }

    // MOVE ACTION
    else {
      node.removeAllActions()

      let duration = 0.3
//      let spinAngle: CGFloat = flipIsHeads() ? 90.0 : -90.0
//      let spinAction = SCNAction.rotateBy(x: 0.0, y: toRadians(angle: spinAngle), z: 0, duration: duration)
//      spinAction.timingMode = .easeInEaseOut
//      node.runAction(spinAction)

      let moveAction = SCNAction.move(to: newPosition, duration: duration)
      moveAction.timingMode = .easeInEaseOut
      node.runAction(moveAction, completionHandler: {
        node.removeAllActions()
        self.drawAvailableZone()
      })
    }

  }
  func positionShip(_ ship: SCNNode, _ startGP: GridPoint, _ shipSize: BoardSize) {
    let boardRange = BoardRange(startGP, shipSize)
    let positionFrame = boxForRange(boardRange)
    let boardDirection = BoardDirection(shipSize)

    //    createOriginIndicator(ship, color: UIColor.blue)
//    createPivotIndicator(ship, color: UIColor.blue)

    // CALCULATE PROPER X
    var finalX: Float = 0.0
    if boardDirection.isVertical {
      finalX = positionFrame.xMax - 0.5
    } else {
      finalX = boardDirection.isLeft ? positionFrame.xMax : positionFrame.xMin
    }
    
    // CALCULATE PROPER Y
    var finalY: Float = 0.0
    if boardDirection.isHorizontal {
      finalY = positionFrame.yMax - 0.5
    } else {
      finalY = boardDirection.isUp ? positionFrame.yMax : positionFrame.yMin
    }
    
    // possition ship
    ship.position = SCNVector3(finalX, -1.0, finalY)
    let delaySec = Double.random(in: 0.05...0.20)
    let delayAction = SCNAction.wait(duration: delaySec)
    let riseAction = SCNAction.move(by: SCNVector3(0.0, 1.0, 0.0), duration: 0.5)
    riseAction.timingMode = .easeOut
    let seqAction = SCNAction.sequence([delayAction, riseAction])
    ship.runAction(seqAction)
    
    // add ship to board
    boardGeom.addChildNode(ship)
    
    // UPDATE CELLS
    cellListFor(BoardRange(startGP, shipSize)).forEach { cell in
      cell.isLabelVisible = false
      cell.shipRef = ship
    }
  }
  func autoPositionShipWithLength(_ length: Int) -> Bool {
    if length > 5 || length < 2 {
      print("[M@] invalid length")
      return false
    }
    let node = makeShip(length)
    var success = false
    let rotations = getRotationArray()
    let column = roll(columns)
    let row = roll(rows)
    
    for angle in rotations {
      node.eulerAngles = SCNVector3Make(0.0, toRadians(angle: Float(angle)), 0.0)
      if placeAtGridPointIfClear(node, GridPoint(column, row)) {
        success = true
        break
      }
    }
    return success
  }
  
}

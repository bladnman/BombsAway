//
//  GridNode.swift
//  BombsAway
//
//  Created by Maher, Matt on 2/28/21.
//

import SceneKit
import UIKit


class Board: SCNNode {
  let columns: Int
  let rows: Int
  let isOwn: Bool

  let top: CGFloat
  let right: CGFloat
  let bottom: CGFloat
  let left: CGFloat

  let sceneView: SCNView!
  var spawnGP: GridPoint!
  var spawnRect: BoardRect!
  let player = PlayerNode()

  let boardGeom = SCNNode()
  var placementStartNode = SCNNode()
  var placementEndNode = SCNNode()

  var cellList = [String: BoardCell]()
  let useNegativeZ = false
  var zMod: Int {
    return useNegativeZ ? -1 : 1
  }

  init(sceneView: SCNView, columns: Int, rows: Int, isOwn: Bool) {
    self.columns = columns
    self.rows = rows
    self.top = CGFloat(rows)
    self.right = CGFloat(columns)
    self.bottom = 0
    self.left = 0
    self.sceneView = sceneView
    self.isOwn = isOwn
    super.init()
    
    addChildNode(boardGeom)
    boardGeom.position = SCNVector3(-Float(columns / 2), Float(0.05), -Float(rows / 2))
    createCells()
    createSpawnRect()
    createShips()
    createPlayer()
      
    takeTurn()
  }
  func takeTurn() {
    drawAvailableZone()
  }

  // MARK: EXTERNAL
  func removeAllShips() {
    // remove all ships
    boardGeom.enumerateChildNodes { node, _ in
      if node.name == C_OBJ_NAME.ship {
        node.removeFromParentNode()
      }
    }
    
    // clear cells
    cellList.forEach { (_, cell) in
      cell.isLabelVisible = true
      cell.shipRef = nil
    }
  }
  func movePlayerTo(_ gp: GridPoint, force: Bool = false) {
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
        if let ship = shipCell.shipRef {
          
          if shipCell.shipRef?.hitAt(shipCell.gridPoint) ?? false {
            print("[M@] we hit! \(shipCell.gridPoint)")
            // update all the cells for this ship
            ship.boardCells?.forEach{ cell in
              cell.updateHitNode()
            }
          }
          
          if ship.isSunk {
            print("[M@] DUDE! YOU SUNK MY BATTLESHIP!")
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

  // MARK: INTERNAL
  private func createCells() {
    for c in 1...columns {
      for r in 1...rows {
        let cellNode = BoardCell(c, r)
        cellNode.position = positionForGridPoint(GridPoint(c, r))
        boardGeom.addChildNode(cellNode)
        setCell(c, r, node: cellNode)
      }
    }
  }
  private func createSpawnRect() {
    spawnGP = GridPoint(roll(columns-2) + 1, roll(rows-2) + 1)
    let firstGP = GridPoint(spawnGP.column - 1, spawnGP.row - 1)
    let lastGP = GridPoint(spawnGP.column + 1, spawnGP.row + 1)
    spawnRect = BoardRect(firstGP: firstGP, lastGP: lastGP)
    
    // SET UP CELLS to be aware of spawn-ness
    cellFor(spawnGP)?.isSpawnPoint = true
    cellListFor(spawnRect).forEach { cell in
      cell.isSpawnRegion = true
    }
  }
  private func createPlayer() {
    moveToGridPoint(player, spawnGP)
  }
  func drawAvailableZone() {
    cellList.forEach { (_, cell) in
      if cell.mode == .move {
        cell.mode = .none
      }
    }
    var availableCellList = cellListForStraights(player.gridPoint, radius: player.stepSize)
    availableCellList = availableCellList + cellListForDiagonals(player.gridPoint, radius: player.stepSize)
    availableCellList.forEach { cell in
      // don't include the cell we are in
      if cell.gridPoint != player.gridPoint {
        cell.mode = .move
      }
    }
  }
  private func createShips() {
    let lengthArray = [5,4,3,3,2];
    for length in lengthArray {
      while !createAndPlaceShipWithLength(length) {
        print("failed ship placement, retrying")
      }
    }
  }
  func createAndPlaceShipWithLength(_ length: Int) -> Bool {
    if length > 5 || length < 2 {
      print("[M@] invalid length")
      return false
    }
    let ship = ShipNode(width: length)
    
    var success = false
    let rotations = getRotationArray()
    let startGP = GridPoint(roll(columns), roll(rows))
    
    for angle in rotations {
      
      // rotate the ship
      ship.eulerAngles = SCNVector3Make(0.0, toRadians(angle: Float(angle)), 0.0)
      
      // get ship size
      let shipSizeVector = rounded(measureToNodeSpace(ship, to: boardGeom))
      
      // get end GP relative to ship size
      let endGP = getEndPoint(startGP, GridPoint(shipSizeVector))

      // OFF BOARD - no placement
      if !isWithinBoard(BoardRect(firstGP: startGP, lastGP: endGP)) {
        continue // next rotation
      }
      
      // set size and direction sets also
      ship.boardSize = BoardSize(shipSizeVector)
      
      let shipCells = cellListFor(BoardRange(startGP, ship.boardSize))
      
      // can a ship be placed in these cells?
      if isClearForShipPlacement(shipCells) {
        positionShip(ship, startGP)
        success = true
        break
      }
    }
    return success
  }
  

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

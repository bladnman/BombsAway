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

  let top: CGFloat
  let right: CGFloat
  let bottom: CGFloat
  let left: CGFloat

  let sceneView: SCNView!
  var spawnGP: GridPoint!
  var spawnRect: BoardRect!

  let boardGeom = SCNNode()
  let player = PlayerNode()
  var placementStartNode = SCNNode()
  var placementEndNode = SCNNode()

  var cellList = [String: BoardCell]()
  let useNegativeZ = false
  var zMod: Int {
    return useNegativeZ ? -1 : 1
  }

  init(sceneView: SCNView, columns: Int, rows: Int) {
    self.columns = columns
    self.rows = rows
    self.top = CGFloat(rows)
    self.right = CGFloat(columns)
    self.bottom = 0
    self.left = 0
    self.sceneView = sceneView
    super.init()
    
    addChildNode(boardGeom)
    boardGeom.position = SCNVector3(-Float(columns / 2), Float(0.05), -Float(rows / 2))
    createCells()
    createSpawnRect()
    createShips()
    createProbeShip()
      
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
  func movePlayerTo(_ gp: GridPoint) {
    guard isValid(gp) else {
      return
    }
    moveToGridPoint(player, gp)
    
  }

  // MARK: INTERNAL
  private func createCells() {
    for c in 1...columns {
      for r in 1...rows {
        let cellNode = BoardCell(c, r)
        cellNode.position = positionForGridPoint(GridPoint(c, r))
        boardGeom.addChildNode(cellNode)
        cellList["\(c), \(r)"] = cellNode
      }
    }
  }
  private func createShips() {
    let lengthArray = [5,4,3,3,2];
    for length in lengthArray {
      while !autoPositionShipWithLength(length) {
        print("failed ship placement, retrying")
        // noop
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
  private func createProbeShip() {
    let boxGeometry = SCNBox(width: 0.7, height: 0.2, length: 0.7, chamferRadius: 0.04)
    boxGeometry.firstMaterial?.diffuse.contents = UIColor.init(white: 0.6, alpha: 0.5)
    player.geometry = boxGeometry
    player.name = C_OBJ_NAME.player
    moveToGridPoint(player, spawnGP)
  }
  func drawAvailableZone() {
    cellList.forEach { (_, cell) in
      cell.mode = .none
    }
//    let availableCellList = cellListFor(player.gridPoint, radius: player.stepSize)
    var availableCellList = cellListStraightsFor(player.gridPoint, radius: player.stepSize)
    availableCellList = availableCellList + cellListDiagonalsFor(player.gridPoint, radius: player.stepSize)
    availableCellList.forEach { cell in
      cell.mode = .move
    }
  }

  

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

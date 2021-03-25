//
//  GridNode.swift
//  BombsAway
//
//  Created by Maher, Matt on 2/28/21.
//

import SceneKit
import UIKit

enum BoardMode {
  case none, move, shoot, probe
}
enum BoardType {
  case offense, defense
}
class Board: SCNNode {
  let columns: Int
  let rows: Int
  let type: BoardType
  var mode: BoardMode = .none { didSet { update() }}
  let top: CGFloat
  let right: CGFloat
  let bottom: CGFloat
  let left: CGFloat

  let sceneView: SCNView!
  var spawnGP: GridPoint!
  var spawnRect: BoardRect!
  let attackShip = AttackShip()

  let boardGeom = SCNNode()
  var placementStartNode = SCNNode()
  var placementEndNode = SCNNode()

  var cellList = [String: BoardCell]()
  let useNegativeZ = false
  var zMod: Int {
    return useNegativeZ ? -1 : 1
  }

  init(sceneView: SCNView, columns: Int, rows: Int, type: BoardType) {
    self.columns = columns
    self.rows = rows
    self.top = CGFloat(rows)
    self.right = CGFloat(columns)
    self.bottom = 0
    self.left = 0
    self.sceneView = sceneView
    self.type = type
    super.init()
    
    addChildNode(boardGeom)
    boardGeom.position = SCNVector3(-Float(columns / 2), Float(0.05), -Float(rows / 2))
    createCells()
    createSpawnRect()
    createShips()
    createAttackShip()
  }

  // MARK: EXTERNAL
  func removeAllShips() {
    // remove all ships
    boardGeom.enumerateChildNodes { boardChild, _ in
      if boardChild.name == C_OBJ_NAME.ship {
        boardChild.removeFromParentNode()
      }
    }
    
    // clear cells
    cellList.forEach { (_, cell) in
      cell.isLabelVisible = true
      cell.targetShipRef = nil
    }
  }
  func performAction(_ gameAction: GameAction) {
    switch gameAction.type {
    case .move:
      if let gp = gameAction.gridPoint {
        stepPlayerShipTo(gp)
      }
    case .probe:
      if let gp = gameAction.gridPoint {
        sendProbeTo(gp)
      }
    case .shoot:
      if let gp = gameAction.gridPoint {
        sendShotTo(gp)
      }
     
    default:
      break
    }
  }


  // MARK: INTERNAL
  func createCells() {
    for c in 1...columns {
      for r in 1...rows {
        let cellNode = BoardCell(c, r)
        cellNode.delegate = self
        cellNode.position = positionForGridPoint(GridPoint(c, r))
        boardGeom.addChildNode(cellNode)
        setCell(c, r, node: cellNode)
        
        // temporary test code, drop some free probes
        if chance(100) {
          cellNode.hasProbe = true
        }
        
      }
    }
  }
  func createSpawnRect() {
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
  func createAttackShip() {
    boardGeom.addChildNode(attackShip)
    attackShip.position = positionForGridPoint(spawnGP)
  }
  func createShips() {
    let lengthArray = [5,4,3,3,2];
    for length in lengthArray {
      while !createAndPlaceShipWithLength(length) {
        // noop
      }
    }
  }
  func createAndPlaceShipWithLength(_ length: Int) -> Bool {
    let ship = TargetShip(width: length)
    
    var success = false
    let rotations = getRotationArray()
    let startGP = GridPoint(roll(columns), roll(rows))
    
    for angle in rotations {
      
      // rotate the ship
      ship.eulerAngles = SCNVector3Make(0.0, toRadians(angle: Float(angle)), 0.0)
      
      // get ship size
      let shipSizeVector = ScnUtils.rounded(ScnUtils.measureToNodeSpace(ship, to: boardGeom))
      
      // get end GP relative to ship size
      let endGP = getEndPoint(startGP, GridPoint(shipSizeVector))

      // OFF BOARD - no placement
      if !isWithinBoard(BoardRect(firstGP: startGP, lastGP: endGP)) {
        continue // next rotation
      }
      
      // set size and direction sets also
      ship.boardSize = BoardSize(shipSizeVector)
      
      let shipCells = cellListFor(BoardRange(startGP, ship.boardSize))
      
      if shipCells.count != length {
        print("[M@] ----[ PROBLEM ]----")
        print("[M@] length", length)
        print("[M@] shipCells", shipCells)
        print("[M@] gps", startGP, endGP)
        print("[M@] ship.boardSize", ship.boardSize)
        print("[M@] shipSizeVector", shipSizeVector)
        let shipCellsTemp = cellListFor(BoardRange(startGP, ship.boardSize))
      }
      
      // can a ship be placed in these cells?
      if isClearForShipPlacement(shipCells) {
        positionShip(ship, startGP)
        success = true
        break
      }
    }
    return success
  }
  
  // MARK: UPDATERS
  func update() {
    clearCellModes()
    switch mode {
    case .move:
      drawAvailableZone(radius: attackShip.stepSize, mode: .move)
    case .probe:
      drawAvailableZone(radius: attackShip.stepSize, mode: .probe)
    case .shoot:
      drawAvailableZone(radius: 6, mode: .shoot)
    default:
      break
    }
  }
  func clearCellModes() {
    cellList.forEach { (_, cell) in
      if C_CELL.SELECTABLE_MODES.contains(cell.mode) {
        cell.mode = .none
      }
    }
  }
  func drawAvailableZone(radius: Int, mode: GameActionType) {
    var availableCellList = [BoardCell]()
    switch mode {
    case .move:
      availableCellList += cellListForStraights(attackShip.gridPoint, radius: radius)
      availableCellList += cellListForDiagonals(attackShip.gridPoint, radius: radius)
    default:
      availableCellList += cellListFor(attackShip.gridPoint, radius: radius)
    }

    
    availableCellList.forEach { cell in
      // don't include the cell we are in
      if cell.gridPoint != attackShip.gridPoint {
        cell.mode = mode
      }
    }
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

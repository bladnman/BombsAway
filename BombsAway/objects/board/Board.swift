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
protocol BoardProtocol {
  func boardActionComplete(gameAction: GameAction, board: Board)
}
class Board: SCNNode {
  let gameStore: GameStore
  let boardStore: BoardStore
  let ownerId: Int
  let viewerId: Int

  let boardSize: BoardSize
  var columns: Int { boardSize.columns }
  var rows: Int { boardSize.rows }
  let type: BoardType
  var mode = GameActionType.none { didSet { update() }}
  let top: CGFloat
  let right: CGFloat
  let bottom: CGFloat
  let left: CGFloat

  let attackShip: AttackShip!
  let delegate: BoardProtocol!

  let boardGeom = SCNNode()
  var placementStartNode = SCNNode()
  var placementEndNode = SCNNode()

  var cellList = [String: BoardCell]()
  let useNegativeZ = false
  var zMod: Int {
    return useNegativeZ ? -1 : 1
  }

  init(gameStore: GameStore, ownerId: Int, viewerId: Int, delegate: BoardProtocol) {
    self.gameStore = gameStore
    self.viewerId = viewerId
    self.ownerId = ownerId
    self.delegate = delegate
    
    self.type = ownerId == viewerId ? .defense : .offense
    self.boardSize = gameStore.gameSettings.boardSize

    
    // - - - - - - - - - - - - - - -
    // MARK: RISK : PLAYER IDs MUST EXIST
    let playerStore = gameStore.playerStoreForId(ownerId)!
    self.boardStore = playerStore.boardStore
    self.attackShip = AttackShip(playerStore: playerStore)
    // - - - - - - - - - - - - - - -
    
    self.top = CGFloat(boardSize.rows)
    self.right = CGFloat(boardSize.columns)
    self.bottom = 0
    self.left = 0

    
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
    
    DispatchQueue.main.async {
      switch gameAction.type {
      case .move:
        if let gp = gameAction.gridPoints.first {
          self.stepAttackShipTo(gp, gameAction: gameAction)
        }
      case .probe:
        for gridPoint in gameAction.gridPoints {
          self.sendProbeTo(gridPoint, gameAction: gameAction)
        }
      case .shoot:
        for gridPoint in gameAction.gridPoints {
          self.sendShotTo(gridPoint, gameAction: gameAction)
        }
      default:
        break
      }
    }
  }


  // MARK: INTERNAL
  func createCells() {
    for c in 1...columns {
      for r in 1...rows {
        let cellNode = BoardCell(c, r, board: self, boardStore: boardStore)
        cellNode.delegate = self
        cellNode.position = positionForGridPoint(GridPoint(c, r))
        boardGeom.addChildNode(cellNode)
        setCell(c, r, node: cellNode)
      }
    }
  }
  func createSpawnRect() {
    // SET UP CELLS to be aware of spawn-ness
    cellFor(boardStore.spawnPoint)?.isSpawnPoint = true
    cellListFor(boardStore.spawnRect).forEach { cell in
      cell.isSpawnRegion = true
    }
  }
  func createAttackShip() {
    boardGeom.addChildNode(attackShip)
    // put ship in player's position or spawnpoint
    if attackShip.playerStore.gridPoint != GridPoint.zero {
      attackShip.position = positionForGridPoint(attackShip.playerStore.gridPoint)
    } else {
      attackShip.position = positionForGridPoint(boardStore.spawnPoint)
      attackShip.playerStore.gridPoint = boardStore.spawnPoint
    }
  }
  func createShips() {
    for shipData in boardStore.ships {
      positionShip(shipData: shipData)
    }
  }

  // MARK: UPDATERS
  func update() {
    clearCellModes()
    
    let attackingPlayerStore = attackShip.playerStore
    switch mode {
    case .move:
      drawAvailableZone(radius: attackingPlayerStore.moveRadius, mode: .move)
    case .probe:
      drawAvailableZone(radius: attackingPlayerStore.probeRadius, mode: .probe)
    case .shoot:
      drawAvailableZone(radius: attackingPlayerStore.shootRadius, mode: .shoot)
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

  func respawn() {
    attackShip.position = positionForGridPoint(boardStore.spawnPoint)
    attackShip.playerStore.gridPoint = boardStore.spawnPoint
    attackShip.animateRespawn()
  }
  func killAttacker() {
    attackShip.animateDeath()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

//
//  Ship.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/10/21.
//

import SceneKit

class TargetShip: SCNNode {
  let NAME: String = C_OBJ_NAME.ship
  var direction = BoardDirection.zero
  var boardSize = BoardSize.zero {
    didSet {
      direction = boardSize.isZero ? BoardDirection.zero : BoardDirection(boardSize)
    }
  }

  var boardCells: [BoardCell]?
  var hits = [String: Bool]()
  var isSunk: Bool { return hits.count == boardCells?.count }

  init(boardSize: BoardSize, color: UIColor = randomShipColor()) {
    super.init()
    self.name = NAME
    
    self.direction = BoardDirection(boardSize)
    
    let width = direction.isHorizontal ? CGFloat(boardSize.columns) : 0.5
    let length = direction.isVertical ? CGFloat(boardSize.rows) : 0.5
    let boxGeometry = SCNBox(width: width, height: 0.2, length: length, chamferRadius: 0.04)
    boxGeometry.firstMaterial?.diffuse.contents = color
    self.geometry = boxGeometry

    // PIVOT POINT:
    //    WIDE: left, bottom, mid-length
    //    WIDE: mid-width, bottom, front
    self.pivot = direction.isHorizontal
      ? SCNMatrix4MakeTranslation(-0.5 * Float(width), -0.1, 0.0)
      : SCNMatrix4MakeTranslation(0.0, -0.1, -0.5 * Float(length))

//    showPivotIndicator()
  }

  func isHitAt(_ gp: GridPoint) -> Bool {
    return hits[gp.toString()] == true
  }

  func isSolidAt(_ gp: GridPoint) -> Bool {
    return hasCellAt(gp) && !isHitAt(gp)
  }

  @discardableResult
  func hitAt(_ gp: GridPoint) -> Bool {
    guard hasCellAt(gp) else {
      return false
    }
    hits[gp.toString()] = true
    updateCells()
    return true
  }

  func hasCellAt(_ gp: GridPoint) -> Bool {
    return cellAt(gp) != nil
  }

  func cellAt(_ gp: GridPoint) -> BoardCell? {
    return boardCells == nil
      ? nil
      : boardCells!.first { $0.gridPoint == gp }
  }

  func updateCells() {
    if let boardCells = boardCells {
      boardCells.forEach { $0.update() }
    }
  }

  override var description: String {
    return super.description + " | isSunk=\(isSunk) | hits=\(hits)"
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

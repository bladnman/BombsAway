//
//  Ship.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/10/21.
//

import SceneKit

class ShipNode: SCNNode {
  let NAME: String = C_OBJ_NAME.ship
  var direction: BoardDirection = BoardDirection.zero
  var boardSize: BoardSize = BoardSize.zero {
    didSet {
      direction = boardSize.isZero ? BoardDirection.zero : BoardDirection(boardSize)
    }
  }
  var boardCells: [BoardCell]?
  var hits = [String: Bool]()
  var isSunk: Bool { return hits.count == boardCells?.count }

  init(width: Int, color: UIColor = randomShipColor()) {
    super.init()
    self.name = self.NAME

    let boxGeometry = SCNBox(width: CGFloat(width), height: 1.0, length: 1.0, chamferRadius: 0.04)
    boxGeometry.firstMaterial?.diffuse.contents = color
    self.geometry = boxGeometry
    
    // PIVOT POINT:  left, bottom, 1/2 length
    self.pivot = SCNMatrix4MakeTranslation(-0.5 * Float(width), -0.5, 0.0)

//    showPivotIndicator()
  }

  func isHitAt(_ gp: GridPoint) -> Bool {
    return hits[gp.toString()] == true
  }
  func isSolidAt(_ gp: GridPoint) -> Bool {
    return hasCellAt(gp) && !isHitAt(gp)
  }
  func hitAt(_ gp: GridPoint) -> Bool {
    guard hasCellAt(gp) else {
      return false
    }
    hits[gp.toString()] = true
    return true
  }
  func hasCellAt(_ gp: GridPoint) -> Bool {
    guard boardCells != nil else {
      return false
    }
    
    return boardCells!.contains(where: { $0.gridPoint == gp })
  }
  
  
  override var description: String {
      return super.description + " | isSunk=\(isSunk) | hits=\(hits)"
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

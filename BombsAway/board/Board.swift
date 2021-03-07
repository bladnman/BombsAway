//
//  GridNode.swift
//  BombsAway
//
//  Created by Maher, Matt on 2/28/21.
//

import SceneKit
import UIKit

struct BoardSize {
  var columns: Int
  var rows: Int
}

extension BoardSize {
  init(_ sizeVector: SCNVector3) {
    self.columns = Int(sizeVector.x)
    self.rows = Int(sizeVector.z)
  }
}

struct BoardRange {
  var columnRange: CountableClosedRange<Int>
  var rowRange: CountableClosedRange<Int>
}

extension BoardRange {
  init(_ gp: GridPoint, _ size: BoardSize) {
    let endCol = gp.column + (size.columns > 0 ? size.columns - 1 : size.columns + 1)
    let endRow = gp.row + (size.rows > 0 ? size.rows - 1 : size.rows + 1)

    self.columnRange = rangeFrom(gp.column, endCol)
    self.rowRange = rangeFrom(gp.row, endRow)
  }
}

struct BoxFrame {
  var xMin: Float
  var xMax: Float
  var yMin: Float
  var yMax: Float
  var xDelta: Float {
    get {
      return xMax - xMin
    }
  }
  var yDelta: Float {
    get {
      return yMax - yMin
    }
  }
  var isHorizontal: Bool {
    get {
      return xMax - xMin > 1
    }
  }
  var isVertical: Bool {
    get {
      return yMax - yMin > 1
    }
  }
}
struct BoardDirection {
  let columns: Float
  let rows: Float
  var isRight: Bool {
    get {
      return columns > 1
    }
  }
  var isLeft: Bool {
    get {
      return columns < -1
    }
  }
  var isDown: Bool {
    get {
      return rows > 1
    }
  }
  var isUp: Bool {
    get {
      return rows < -1
    }
  }
  var isHorizontal: Bool {
    get {
      return isLeft || isRight
    }
  }
  var isVertical: Bool {
    get {
      return isUp || isDown
    }
  }
  init(_ size: BoardSize) {
    self.columns = Float(size.columns)
    self.rows = Float(size.rows)
  }
}

class Board: SCNNode {
  let columns: Int
  let rows: Int
  let sceneView: SCNView!

  let top: CGFloat
  let right: CGFloat
  let bottom: CGFloat
  let left: CGFloat

  let boardNode = SCNNode()
  var cellList = [String: BoardCell]()
  var gridlineColor = UIColor.white
  var gridlineRadius = 0.05

  let useNegativeZ = false
  var zMod: Int {
    return useNegativeZ ? -1 : 1
  }

  convenience init(_ sceneView: SCNView, _ columns: Int, _ rows: Int) {
    self.init(sceneView: sceneView, columns: columns, rows: rows)
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

    addChildNode(boardNode)

    _createBoard()
    createOriginIndicator(self, color: UIColor.gray)
    createOriginIndicator(boardNode, color: UIColor.orange)
  }

  // MARK: POSITIONERS

  @discardableResult
  func placeAtGridPointIfClear(_ node: SCNNode, _ startGP: GridPoint) -> Bool {

    clearHitTestObjects()

    let shipSizeVector = rounded(measureToNodeSpace(node, to: boardNode))
    let endGP = _getEndPoint(startGP, GridPoint(shipSizeVector))
    
    let startPosition = _positionForGridPoint(startGP, andHeight: 0.2)
    let endPosition = _positionForGridPoint(endGP, andHeight: 0.2)

    addHitTestObject(startPosition, withColor: UIColor.green)
    addHitTestObject(endPosition, withColor: UIColor.gray)

    
    // OFF BOARD - no place
    if startGP.column < 1 || startGP.column > 10 ||
        startGP.row < 1 || startGP.row > 10 ||
        endGP.column < 1 || endGP.column > 10 ||
        endGP.row < 1 || endGP.row > 10 {
      return false
    }

    // SEE IF SPOTS ARE AVAILABLE
    let shipSize = BoardSize(shipSizeVector)
    if cellListFor(BoardRange(startGP, shipSize))
        .contains(where: { $0.shipRef != nil }) {
      return false
    }
    
    // SUCCESS
    _positionShip(node, startGP, shipSize)

    print("[M@] ----------------")
    print("[M@] start cell    [\(String(describing: cellFor(startGP)))]")
    print("[M@] startGP       [\(startGP)]")
    print("[M@] endGP         [\(endGP)]")
    print("[M@] ship size     [\(shipSize)]")
    print("[M@] added ✅")

    return true
  }
  func _positionShip(_ ship: SCNNode, _ startGP: GridPoint, _ shipSize: BoardSize) {
    let boardRange = BoardRange(startGP, shipSize)
    let positionFrame = _boxForRange(boardRange)
    let boardDirection = BoardDirection(shipSize)

    //    createOriginIndicator(ship, color: UIColor.blue)
    createPivotIndicator(ship, color: UIColor.blue)

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
    ship.position = SCNVector3(finalX, 0, finalY)
    
    // add ship to board
    boardNode.addChildNode(ship)
    
    // UPDATE CELLS
    cellListFor(BoardRange(startGP, shipSize)).forEach { cell in
      cell.isLabelVisible = false
      cell.shipRef = ship
    }
  }
  func _boxForRange(_ boardRange: BoardRange) -> BoxFrame {
    return BoxFrame(
      xMin: Float(boardRange.columnRange.min() ?? 0) - 0.5,
      xMax: Float(boardRange.columnRange.max() ?? 0) + 0.5,
      yMin: Float(boardRange.rowRange.min() ?? 0) - 0.5,
      yMax: Float(boardRange.rowRange.max() ?? 0) + 0.5)
  }
  func _getEndPoint(_ startGP: GridPoint, _ sizeGP: GridPoint) -> GridPoint {
    let nearEndGP = startGP + sizeGP

    // adjust for the start point
    return GridPoint(
      nearEndGP.column > startGP.column ? nearEndGP.column - 1 : nearEndGP.column + 1,
      nearEndGP.row > startGP.row ? nearEndGP.row - 1 : nearEndGP.row + 1)
  }
  func moveToGridPoint(_ node: SCNNode, _ gp: GridPoint) {
    let newToGrid = node.parent != boardNode
    if newToGrid {
      boardNode.addChildNode(node)
    }

    let newPosition = _positionForGridPoint(gp)

    // JUST ADD NEW ITEMS
    if newToGrid {
      // cells are 0-index, thus -1s
      node.position = newPosition
    }

    // MOVE ACTION
    else {
      node.removeAllActions()

      let duration = 0.6
      let spinAngle: CGFloat = flipIsHeads() ? 90.0 : -90.0
      let spinAction = SCNAction.rotateBy(x: 0.0, y: toRadians(angle: spinAngle), z: 0, duration: duration)
      spinAction.timingMode = .easeInEaseOut
      node.runAction(spinAction)

      let moveAction = SCNAction.move(to: newPosition, duration: duration)
      moveAction.timingMode = .easeOut
      node.runAction(moveAction, completionHandler: {
        node.removeAllActions()
      })
    }

  }
  func clearHitTestObjects() {
    boardNode.enumerateChildNodes { node, _ in
      if node.name == "HIT-TEST-OBJECT" {
        node.removeFromParentNode()
      }
    }
  }
  func addHitTestObject(_ position: SCNVector3, withColor: UIColor) {
    let boxGeometry = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0.2)
    boxGeometry.firstMaterial?.diffuse.contents = withColor
//    boxGeometry.firstMaterial?.transparency = 0.4
    let node = SCNNode(geometry: boxGeometry)
    node.name = "HIT-TEST-OBJECT"
    node.position = position
    boardNode.addChildNode(node)
  }
  func removeAllShips() {
    // remove all ships
    boardNode.enumerateChildNodes { node, _ in
      if node.name == "SHIP" {
        node.removeFromParentNode()
      }
    }
    
    // clear cells
    cellList.forEach { (_, cell) in
      cell.isLabelVisible = true
      cell.shipRef = nil
    }
  }

  // MARK: BOARD WORKERS

  func _createBoard() {
    boardNode.position = SCNVector3(-Float(columns / 2), Float(0.05), -Float(rows / 2))
    for c in 1...columns {
      for r in 1...rows {
        let cellNode = BoardCell(c, r)
        cellNode.position = _positionForGridPoint(GridPoint(c, r))
        boardNode.addChildNode(cellNode)
        cellList["\(c), \(r)"] = cellNode
      }
    }
  }

  func cellFor(_ gridPoint: GridPoint) -> BoardCell? {
    return cellList["\(gridPoint.column), \(gridPoint.row)"]
  }

  func cellListFor(_ boardRange: BoardRange) -> [BoardCell] {
    var cellList = [BoardCell]()
    for c in boardRange.columnRange {
      for r in boardRange.rowRange {
        if let cell = cellFor(GridPoint(c, r)) {
          cellList.append(cell)
        }
      }
    }
    return cellList
  }

  // MARK: UTILS

  func _positionForGridPoint(_ gridPoint: GridPoint) -> SCNVector3 {
    return _positionForGridPoint(gridPoint, andHeight: 0.0)
  }

  func _positionForGridPoint(_ gridPoint: GridPoint, andHeight: Float) -> SCNVector3 {
    return SCNVector3(Float(gridPoint.column), andHeight, Float(gridPoint.row * zMod))
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

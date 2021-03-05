//
//  GridNode.swift
//  BombsAway
//
//  Created by Maher, Matt on 2/28/21.
//

import SceneKit
import UIKit

class GridNode: SCNNode {
  let columns: Int
  let rows: Int
  let boardNode = SCNNode()

  var gridlineColor = UIColor.white
  var gridlineRadius = 0.05

  let top: CGFloat
  let right: CGFloat
  let bottom: CGFloat
  let left: CGFloat

  let useNegativeZ = true
  var zMod: Int {
    return useNegativeZ ? -1 : 1
  }

  convenience init(_ columns: Int, _ rows: Int) {
    self.init(columns: columns, rows: rows)
  }

  init(columns: Int, rows: Int) {
    self.columns = columns
    self.rows = rows
    self.top = CGFloat(rows)
    self.right = CGFloat(columns)
    self.bottom = 0
    self.left = 0
    super.init()

    addChildNode(boardNode)

    _drawGrid()
  }

  // MARK: POSITIONERS

  func placeAtGridPointIfClear(_ node: SCNNode, column: Int, row: Int) -> Bool {
    
    clearHitTestObjects()
    
    let sizeLocal = measure(node)
    let sizeToBoard = rounded(measureToNodeSpace(node, to: boardNode))

    let startPosition = _positionForGridPoint(column, row, andHeight: 0.5)
    
    let endCol = column + Int(sizeToBoard.x) - 1 // -1 to discount start column
    let endRow = row + Int(sizeToBoard.z) - 1 // -1 to discount start row
    let endPosition = _positionForGridPoint(endCol, endRow, andHeight: 0.5)

    addHitTestObject(startPosition, withColor: UIColor.yellow)
    addHitTestObject(endPosition, withColor: UIColor.green)
    
    let hitNodes = boardNode.hitTestWithSegment(from: startPosition, to: endPosition, options: nil)
    print("[M@] ----------------")
    print("[M@] sizeLocal         [\(sizeLocal)]")
    print("[M@] sizeToBoard       [\(sizeToBoard)]")
    print("[M@] start coord       [\(startPosition.x), \(startPosition.z)]")
    print("[M@] end coord         [\(endPosition.x), \(endPosition.z)]")
    print("[M@] [\(hitNodes)]")
    print("[M@] placeAtGridPointIfClear [\(column), \(row)]")
  
    // SUCCESS
    if hitNodes.isEmpty {
      boardNode.addChildNode(node)
      node.position = startPosition
    }
    
    return hitNodes.isEmpty
  }

  func moveToGridPoint(_ node: SCNNode, column: Int, row: Int) {
    let newToGrid = node.parent != boardNode
    if newToGrid {
      boardNode.addChildNode(node)
    }

    let newPosition = _positionForGridPoint(column, row)

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

    logGridMap()
  }

  func clearHitTestObjects() {
    boardNode.enumerateChildNodes { node, _ in
      if node.name == "HIT-TEST-OBJECT" {
        node.removeFromParentNode()
      }
    }
  }

  func addHitTestObject(_ position: SCNVector3, withColor: UIColor) {
    print("[M@] test obj at [\(position)]")
    let boxGeometry = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0.2)
    boxGeometry.firstMaterial?.diffuse.contents = withColor
//    boxGeometry.firstMaterial?.transparency = 0.4
    let node = SCNNode(geometry: boxGeometry)
    node.name = "HIT-TEST-OBJECT"
    node.position = position
    boardNode.addChildNode(node)
  }

  func logGridMap() {
    // what is in 6,3
//    let positionLow = SCNVector3(6, 0, -3)
//    let positionHigh = SCNVector3(6, 1, -3)
//
//    let hitNodes = boardNode.hitTestWithSegment(from: positionLow, to: positionHigh, options: nil)

//    print("[M@] [\(hitNodes)]")
  }

  // MARK: GRID WORKERS

  func _drawGrid() {
    boardNode.position = SCNVector3(-Float(columns / 2), Float(0.05), -Float(rows / 2))
    _drawGridCells()
    _numberCells()
  }

  func _drawGridCells() {
    for c in 1...columns {
      for r in 1...rows {
        let cellNode = GridCell(c, r)
        // draw as if 0-indexed
        cellNode.position = _positionForGridPoint(c, r)
        cellNode.geometry?.firstMaterial?.diffuse.contents = UIColor.darkGray
        cellNode.rotation = SCNVector4Make(1, 0, 0, .pi / 2 * 3)
        boardNode.addChildNode(cellNode)
      }
    }
  }

  func _numberCells() {
    for c in 1...columns {
      for r in 1...rows {
        let node = makeText(text: "\(c),\(r)",
                            depthOfText: 5.0,
                            color: UIColor.lightGray,
                            transparency: 1.0)

        node.position = _positionForGridPoint(c, r, andHeight: 0.1)
        node.rotation = SCNVector4Make(1, 0, 0, .pi / 2 * 3)

        boardNode.addChildNode(node)
      }
    }
  }

  func makeText(text: String, depthOfText: CGFloat, color: UIColor, transparency: CGFloat) -> SCNNode {
    // 1. Create An SCNNode With An SCNText Geometry
    let textNode = SCNNode()
    let textGeometry = SCNText(string: text, extrusionDepth: depthOfText)

    // 2. Set The Colour Of Our Text, Our Font & It's Size
    textGeometry.firstMaterial?.diffuse.contents = color
    textGeometry.firstMaterial?.isDoubleSided = true
    textGeometry.font = UIFont(name: "Skia-Regular_Black", size: 100)
    textGeometry.firstMaterial?.transparency = transparency

    // 3. Set It's Flatness To 0 So It Looks Smooth
    textGeometry.flatness = 0

    // 4. Set The SCNNode's Geometry
    textNode.geometry = textGeometry

    // center the pivot point
    let min = textNode.boundingBox.min
    let max = textNode.boundingBox.max
    let w = CGFloat(max.x - min.x)
    let h = CGFloat(max.y - min.y)
    let l = CGFloat(max.z - min.z)
    textNode.pivot = SCNMatrix4MakeTranslation(Float(w / 2), Float(h / 2), Float(l / 2))

    let scale = 0.02
    textNode.scale = SCNVector3(scale, scale, scale)

    return textNode
  }

  // MARK: UTILS

  func _positionForGridPoint(_ column: Int, _ row: Int) -> SCNVector3 {
    return _positionForGridPoint(column, row, andHeight: 0.0)
  }

  func _positionForGridPoint(_ column: Int, _ row: Int, andHeight: Float) -> SCNVector3 {
    return SCNVector3(Float(column), andHeight, Float(row * zMod))
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

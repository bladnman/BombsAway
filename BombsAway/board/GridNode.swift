//
//  GridNode.swift
//  BombsAway
//
//  Created by Maher, Matt on 2/28/21.
//

import SceneKit
import UIKit

class BoardNode: SCNNode {
  let columns: Int
  let rows: Int
  let sceneView: SCNView!
  
  let top: CGFloat
  let right: CGFloat
  let bottom: CGFloat
  let left: CGFloat

  let boardNode = SCNNode()
  var cells = [String: GridCell]()
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

    _drawGrid()
  }


  // MARK: POSITIONERS
  @discardableResult
  func placeAtGridPointIfClear(_ node: SCNNode, _ startGP: GridPoint) -> Bool {
    print("[M@] ----------------")
    clearHitTestObjects()
    
    let sizeToBoard = rounded(measureToNodeSpace(node, to: boardNode))
    let endGP = _getEndPoint(startGP, GridPoint(sizeToBoard))
    
    let startPosition = _positionForGridPoint(startGP, andHeight: 0.2)
    let endPosition = _positionForGridPoint(endGP, andHeight: 0.2)

    print("[M@] startPosition [\(startPosition)]")
    print("[M@] firstShip [\(String(describing: boardNode.childNodes.last?.position))]")
    
    
    addHitTestObject(startPosition, withColor: UIColor.yellow)
    addHitTestObject(endPosition, withColor: UIColor.green)
    
    let options : [String: Any] = [SCNHitTestOption.backFaceCulling.rawValue: false,
                                           SCNHitTestOption.searchMode.rawValue: 1,
                                           SCNHitTestOption.ignoreChildNodes.rawValue : false,
                                           SCNHitTestOption.ignoreHiddenNodes.rawValue : false]
    
    let hitResults = boardNode.hitTestWithSegment(from: startPosition, to: endPosition, options: options)
    let hitShips = hitResults.filter { hitResult in
      return hitResult.node.name == "SHIP"
    }
    print("[M@] start cell  [\(String(describing: cellFor(startGP)))]")
    print("[M@] startGP     [\(startGP)]")
    print("[M@] endGP       [\(endGP)]")
    print("[M@] shipSizeGP  [\(GridPoint(sizeToBoard))]")

    // SUCCESS
    if hitShips.isEmpty {
      boardNode.addChildNode(node)
      node.position = startPosition
      print("[M@] added ✅")
    } else {
//      dumpHitResults(hitResults, "Board Node Segment Hits")
      print("[M@] shipCount   [\(hitShips.count)]")
      print("[M@] hitShips    [\(hitShips)]")
    }
    
    return hitShips.isEmpty
  }
  func _getEndPoint(_ startGP: GridPoint, _ sizeGP: GridPoint) -> GridPoint {
    let nearEndGP = startGP + sizeGP
    
    // adjust for the start point
    return GridPoint(
      nearEndGP.column > startGP.column ? nearEndGP.column - 1 : nearEndGP.column + 1,
      nearEndGP.row > startGP.row ? nearEndGP.row - 1 : nearEndGP.row + 1
    )
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
  func removeAllShips() {
    boardNode.enumerateChildNodes { node, _ in
      if node.name == "SHIP" {
        node.removeFromParentNode()
      }
    }
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
        cellNode.position = _positionForGridPoint(GridPoint(c, r))
        cellNode.geometry?.firstMaterial?.diffuse.contents = UIColor.darkGray
        cellNode.rotation = SCNVector4Make(1, 0, 0, .pi / 2 * 3)
        boardNode.addChildNode(cellNode)
        
        // keep track of our cells
        cells["\(c), \(r)"] = cellNode
      }
    }
  }
  func cellFor(_ gridPoint: GridPoint) -> GridCell? {
    return cells["\(gridPoint.column), \(gridPoint.row)"]
  }
  func cellFor(_ column: Int, _ row: Int) -> GridCell? {
    return cellFor(GridPoint(column, row))
  }
  func _numberCells() {
    for c in 1...columns {
      for r in 1...rows {
        let node = makeText(text: "\(c),\(r)",
                            depthOfText: 5.0,
                            color: UIColor.lightGray,
                            transparency: 1.0)

        node.position = _positionForGridPoint(GridPoint(c, r), andHeight: 0.1)
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

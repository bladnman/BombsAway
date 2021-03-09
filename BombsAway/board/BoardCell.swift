//
//  GridCell.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/1/21.
//

import SceneKit

class BoardCell: SCNNode {
  let column: Int
  let row: Int
  
  
  var mode = C_CELL_MODE.none {
    didSet {
      updateFloor()
    }
  }
  var _label: SCNNode?
  var floorNode: SCNNode!
  var shipRef: SCNNode?
  var isSpawnPoint = false {
    didSet {
      if isSpawnPoint {
        isSpawnRegion = true
      }
    }
  }
  var isSpawnRegion = false {
    didSet {
      updateFloor()
    }
  }
  
  var isLabelVisible: Bool = false {
    didSet {
      updateLabel()
    }
  }
  var isHighlighted: Bool = false {
    didSet {
      updateFloor()
    }
  }
  var floorColor: UIColor {
    get {
      switch mode {
      case .highlight:
        return UIColor.fromHex("#778ca3")
      case .move:
        return UIColor.fromHex("#778ca3")
      default:
        break
      }
      if isHighlighted {
        return UIColor.fromHex("#778ca3")
      }
      if isSpawnRegion {
        return UIColor.fromHex("#303952")
      }
      return UIColor.fromHex("#34495e")
    }
  }
  
  init(_ column: Int, _ row: Int) {
    self.column = column
    self.row = row
    super.init()
    
    createFloor()
    updateLabel()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  func createFloor() {
    let geom = SCNBox(width: 1.0, height: 0.07, length: 1.0, chamferRadius: 0.02)
//    let geom = SCNBox(width: 0.98, height: 0.07, length: 0.98, chamferRadius: 0.0)

    floorNode = SCNNode(geometry: geom)
    floorNode?.geometry?.firstMaterial?.diffuse.contents = floorColor
    floorNode.name = C_OBJ_NAME.cellFloor
    floorNode.rotation = SCNVector4Make(1, 0, 0, .pi / 2 * 2)
    floorNode.position = SCNVector3(0,0,0)
    
    addChildNode(floorNode)
  }
  func updateFloor() {
    floorNode?.geometry?.firstMaterial?.diffuse.contents = floorColor
  }
  
  
  // MARK: LABEL
  func updateLabel() {
    // SHOW
    if isLabelVisible {
      if _label == nil {
        _label = makeText(text: "\(column),\(row)",
                          depthOfText: 3.0,
                          color: UIColor.fromHex("#95a5a6"),
                          transparency: 1.0)
        _label!.position = SCNVector3(0.0, 0.1, 0.0)
        _label!.name = C_OBJ_NAME.label
        _faceUp(_label!)
        addChildNode(_label!)
      }
    }
    
    // HIDE
    else {
      self._label?.removeFromParentNode()
      self._label = nil
    }
  }
  func _faceUp(_ node: SCNNode) {
    node.rotation = SCNVector4Make(1, 0, 0, .pi / 2 * 3)
  }
}

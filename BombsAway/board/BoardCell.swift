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
  
  var _label: SCNNode?
  var shipRef: SCNNode?
  
  var isLabelVisible: Bool = true {
    didSet {
      updateLabel()
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
    let floor = SCNPlane(width: 1.0, height: 1.0)
    floor.firstMaterial?.diffuse.contents = UIColor.darkGray
    
    let floorNode = SCNNode(geometry: floor)
    floorNode.name = "FLOOR"
    _faceUp(floorNode)
    floorNode.position = SCNVector3(0,0,0)
    addChildNode(floorNode)
  }
  
  
  // MARK: LABEL
  func updateLabel() {
    // SHOW
    if isLabelVisible {
      if _label == nil {
        _label = makeText(text: "\(column),\(row)",
                          depthOfText: 3.0,
                          color: UIColor.orange,
                          transparency: 1.0)
        _label!.position = SCNVector3(0.0, 0.1, 0.0)
        _label!.name = "LABEL"
        _faceUp(_label!)
        addChildNode(_label!)
      }
    }
    
    // HIDE
    else {
      if let label = _label {
        label.removeFromParentNode()
      }
    }
  }
  func _faceUp(_ node: SCNNode) {
    node.rotation = SCNVector4Make(1, 0, 0, .pi / 2 * 3)
  }
}

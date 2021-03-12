//
//  GridCell.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/1/21.
//

import SceneKit

class BoardCell: SCNNode {
  let NAME: String = C_OBJ_NAME.boardCell
  let column: Int
  let row: Int
  var gridPoint: GridPoint {
    return GridPoint(column, row)
  }
  var mode = C_CELL_MODE.none {
    didSet {
      updateFloor()
    }
  }

  var _label: SCNNode?
  var floorNode: SCNNode!
  var shipRef: ShipNode?
  var floorColor: UIColor {
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

  // MARK: ISers
  var isSpawnPoint: Bool = false {
    didSet {
      if isSpawnPoint {
        isSpawnRegion = true
      }
    }
  }
  var isSpawnRegion: Bool = false {
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
  var hasSolidShip: Bool { return shipRef?.isSolidAt(gridPoint) ?? false }
  var hasAnyShip: Bool { return shipRef != nil }
  var isClearForShipPlacement: Bool { return !hasAnyShip && !isSpawnRegion }
  var isClearForMovement: Bool { return !hasSolidShip }
  
  
  init(_ column: Int, _ row: Int) {
    self.column = column
    self.row = row
    super.init()

    self.name = NAME

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
    floorNode.position = SCNVector3(0, 0, 0)

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
        _label = makeText(text: gridPoint.toString(),
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
      _label?.removeFromParentNode()
      _label = nil
    }
  }
  func _faceUp(_ node: SCNNode) {
    node.rotation = SCNVector4Make(1, 0, 0, .pi / 2 * 3)
  }
  
  
  // MARK: HITS
  func updateHitNode() {
    print("[M@] updating [\(gridPoint)]")
    // make sure we're hit
    if let ship = shipRef {
      guard ship.isHitAt(gridPoint) else {
        return
      }
      print("[M@] ship is hit at [\(gridPoint)]")
    }
    
//    let image = UIImage(named: "art.scnassets/red-splat.png")
//    let node = SCNNode(geometry: SCNPlane(width: 1, height: 1))
//    node.geometry?.firstMaterial?.diffuse.contents = image
//    node.constraints = [SCNBillboardConstraint()]
//    node.pivot = SCNMatrix4MakeTranslation(0.0, -0.5, 0.0)
//    addChildNode(node)
    
    updateHitCoin()
  }
  func updateHitCoin() {
    removeHitCoint()
    
    if let ship = shipRef {
      // make sure we're hit
      guard ship.isHitAt(gridPoint) else {
        return
      }
      // sunk or not
      let path = ship.isSunk ? "art.scnassets/coin-test-red.scn" : "art.scnassets/coin-test.scn"
      
      let scene = SCNScene(named: path)!
      let node = scene.rootNode.childNode(withName: "cointest", recursively: true)!
      node.name = C_OBJ_NAME.hitcoin
      
      addChildNode(node)
    }

  }
  func removeHitCoint() {
    childNodes
      .filter({$0.name == C_OBJ_NAME.hitcoin})
      .forEach { coin in
      coin.removeFromParentNode()
    }
  }
}

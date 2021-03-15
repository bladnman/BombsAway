//
//  GridCell.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/1/21.
//

import SceneKit

class BoardCell: SCNNode {
  let NAME: String = C_OBJ_NAME.boardCell
  let gridPoint: GridPoint!
  var mode = C_CELL_MODE.none { didSet { update() } }

  // MARK: CELL ELEMENTS
  // only one of:
  var targetShipRef: TargetShip?
  var collectable: SCNNode?
  var shotStatusIndicator: SCNNode?
  
  var baseNode: SCNNode!
  var floor: SCNNode!
  
  // any number of:
  var gpLabel: SCNNode?
  var probe: SCNNode?
  var potentialIndicator: SCNNode?
  var spawnPointIndicator: SCNNode?
  var spawnAreaIndicator: SCNNode?
  var selectableIndicator: SCNNode!
  
  
  var floorColor: UIColor {
    switch mode {
    case .highlight:
      return UIColor.fromHex("#778ca3")
    case .move:
      return UIColor.fromHex("#3e4852")
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
  var isSpawnPoint: Bool = false { didSet { update() } }
  var isSpawnRegion: Bool = false { didSet { update() } }
  var isLabelVisible: Bool = false { didSet { update() } }
  var isHighlighted: Bool = false { didSet { update() } }
  
  var hasSolidShip: Bool { return targetShipRef?.isSolidAt(gridPoint) ?? false }
  var hasAnyShip: Bool { return targetShipRef != nil }
  var isClearForShipPlacement: Bool { return !hasAnyShip && !isSpawnRegion }
  var isClearForMovement: Bool { return !hasSolidShip }
  
  
  init(_ column: Int, _ row: Int) {
    self.gridPoint = GridPoint(column, row)
    super.init()

    self.name = NAME

    installBaseScene()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func installBaseScene() {
    baseNode = deepCopyNode(Models.boardCell)
    addChildNode(baseNode)
    
    floor = getChildWithName(baseNode.childNodes, name: C_OBJ_NAME.cellFloor)

    selectableIndicator = deepCopyNode(Models.selectableIndicator)
    selectableIndicator.opacity = 0.0
    addChildNode(selectableIndicator)
    
    
    update()
  }
  
  
  // MARK: UPDATES
  func update() {
    updateFloor()
    updateLabel()
    updateHitNode()
    updateSelectableIndicator()
  }
  func updateFloor() {
    floor?.geometry?.firstMaterial?.diffuse.contents = floorColor
  }
  func updateSelectableIndicator() {
    
    if mode == .move {
      showSelectableIndicator()
//      selectableIndicator?.position = SCNVector3(0, -0.2, 0)
//      selectableIndicator?.opacity = 0.0
//      let fadeAction = SCNAction.fadeIn(duration: 0.75)
//      let moveAction = SCNAction.move(to: SCNVector3(0, 0.1 ,0), duration: 0.5)
//      moveAction.timingMode = .easeOut
//      selectableIndicator!.runAction(SCNAction.group([moveAction, fadeAction]))
      
    } else {
      hideSelectableIndicator()
//      if let node = self.selectableIndicator {
//        let fadeAction = SCNAction.fadeOut(duration: 0.3)
//        let moveAction = SCNAction.move(to: SCNVector3(0, -0.2, 0), duration: 0.3)
//        moveAction.timingMode = .easeOut
//        node.runAction(SCNAction.group([moveAction, fadeAction])) {
//          node.removeFromParentNode()
//        }
//      }
    }
  }
  func showSelectableIndicator(_ duration: Double = C_MOVE.BoardCell.SelectIndicator.fadeInSec) {
    
    selectableIndicator.removeAction(forKey: "fadeIn")
    selectableIndicator.removeAction(forKey: "fadeOut")

    let fadeAction = SCNAction.fadeIn(duration: duration)
    fadeAction.timingMode = .easeInEaseOut
    selectableIndicator!.runAction(fadeAction, forKey: "fadeIn")
  }
  func hideSelectableIndicator(_ duration: Double = C_MOVE.BoardCell.SelectIndicator.fadeOutSec) {
    selectableIndicator.removeAction(forKey: "fadeIn")
    selectableIndicator.removeAction(forKey: "fadeOut")
    
    let fadeAction = SCNAction.fadeOut(duration: duration)
    fadeAction.timingMode = .easeOut
    selectableIndicator!.runAction(fadeAction, forKey: "fadeOut")
  }

  // MARK: LABEL
  func updateLabel() {
    // SHOW
    if isLabelVisible {
      if gpLabel == nil {
        gpLabel = makeText(text: gridPoint.toString(),
                          depthOfText: 3.0,
                          color: UIColor.fromHex("#95a5a6"),
                          transparency: 1.0)
        gpLabel!.position = SCNVector3(0.0, 0.1, 0.0)
        gpLabel!.name = C_OBJ_NAME.label
        _faceUp(gpLabel!)
        addChildNode(gpLabel!)
      }
    }

    // HIDE
    else {
      gpLabel?.removeFromParentNode()
      gpLabel = nil
    }
  }
  func _faceUp(_ node: SCNNode) {
    node.rotation = SCNVector4Make(1, 0, 0, .pi / 2 * 3)
  }
  
  
  // MARK: HITS
  func updateHitNode() {
    
    // NO SHIP - bail
    guard let targetShip = targetShipRef else {
      removeHitCoint()
      return
    }
    
    // NOT HIT - bail
    guard targetShip.isHitAt(gridPoint) else {
      removeHitCoint()
      return
    }
    
//    let image = UIImage(named: "art.scnassets/red-splat.png")
//    let node = SCNNode(geometry: SCNPlane(width: 1, height: 1))
//    node.geometry?.firstMaterial?.diffuse.contents = image
//    node.constraints = [SCNBillboardConstraint()]
//    node.pivot = SCNMatrix4MakeTranslation(0.0, -0.5, 0.0)
//    addChildNode(node)
    
    createHitCoin()
  }
  func createHitCoin() {
    // remove first (in case we toggled from hit to sunk)
    removeHitCoint()
    
    if let ship = targetShipRef {
      // NOT HIT - bail
      guard ship.isHitAt(gridPoint) else {
        return
      }
      
      // sunk or not
      let coin = ship.isSunk ? Models.redCoin.clone() : Models.blueCoin.clone()
      coin.name = C_OBJ_NAME.hitcoin
      addChildNode(coin)
    }
  }
  func removeHitCoint() {
    childNodes
      .filter { $0.name == C_OBJ_NAME.hitcoin }
      .forEach { coin in coin.removeFromParentNode() }
  }
}

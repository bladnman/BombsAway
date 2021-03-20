//
//  GridCell.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/1/21.
//

import SceneKit
protocol BoardCellDelegate {
  func bcellGetSurroundingProbeCount(_ gp: GridPoint) -> Int
}
class BoardCell: SCNNode {
  
  let NAME: String = C_OBJ_NAME.boardCell
  var probability: CellProbabilityController!
  var delegate: BoardCellDelegate?
  // data
  let gridPoint: GridPoint!
  var mode = C_CELL_MODE.none { didSet { update() } }
  
  // MARK: CELL ELEMENTS
  // only one of:
  var baseNode: SCNNode!
  var floor: SCNNode!
  var targetShipRef: TargetShip? {
    didSet {
      DispatchQueue.main.async {
        self.update()
      }
    }
  }
  var collectable: SCNNode?
  var shotStatusIndicator: SCNNode?
  var probe: SCNNode?
  
  // any number of:
  var gpLabel: SCNNode?
  var potentialIndicator: SCNNode?
  var spawnPointIndicator: SCNNode?
  var spawnAreaIndicator: SCNNode?
  var selectableIndicator: SCNNode!
  
  
  var floorColor: UIColor {
    return probability.getFloorColor()
    
    
//    switch mode {
//    case .highlight:
//      return UIColor.fromHex("#778ca3")
//    case .move:
//      return UIColor.fromHex("#3e4852")
//    default:
//      break
//    }
//    if isHighlighted {
//      return UIColor.fromHex("#778ca3")
//    }
//    if isSpawnRegion {
//      return UIColor.fromHex("#303952")
//    }
//    return UIColor.fromHex("#34495e")
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
  var hasCollectible: Bool = false
  var hasProbe: Bool = false {
    didSet {
      updateProbe()
    }
  }
  
  
  init(_ column: Int, _ row: Int) {
    self.gridPoint = GridPoint(column, row)

    super.init()
    
    self.name = NAME
    
    self.probability = CellProbabilityController(self)

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
  
  // MARK: SELECTION INDICATOR
  func updateSelectableIndicator() {
    if mode == .move {
      showSelectableIndicator()
    } else {
      hideSelectableIndicator()
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
  
  
  // MARK: HIT INDICATOR
  func updateHitNode() {
    
    // NO SHIP - bail
    guard let targetShip = targetShipRef else {
      removeHitCoin()
      return
    }
    
    // NOT HIT - bail
    guard targetShip.isHitAt(gridPoint) else {
      removeHitCoin()
      return
    }
    createHitCoin()
  }
  func createHitCoin() {
    // remove first (in case we toggled from hit to sunk)
    removeHitCoin()
    
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
  func removeHitCoin() {
    childNodes
      .filter { $0.name == C_OBJ_NAME.hitcoin }
      .forEach { coin in coin.removeFromParentNode() }
  }
  
  
  // MARK: PROBE
  func updateProbe() {
    if hasProbe {
      showProbe()
    } else {
      hideProbe()
    }
  }
  func showProbe() {
    // already showing probe - bail
    guard probe == nil else { return }
    
    probe = Models.cellProbe.clone()
    addChildNode(probe!)
    
//    let gaussianBlur    = CIFilter(name: "CIGaussianBlur")
//    gaussianBlur?.name  = "blur"
//    gaussianBlur?.setValue(1, forKey: "inputRadius")
//    probe?.filters        = [gaussianBlur] as? [CIFilter]
  }
  func hideProbe() {
    // not showing probe - bail
    guard probe != nil else { return }
    
    probe?.removeFromParentNode()
    probe = nil
  }
}

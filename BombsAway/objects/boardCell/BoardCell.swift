//
//  GridCell.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/1/21.
//

import SceneKit
protocol BoardCellDelegate {
  func bcellGetSurroundingProbeCount(_ gp: GridPoint) -> Int
  func bcellGetSurroundingThreats(_ gp: GridPoint) -> ThreatDirections
}

class BoardCell: SCNNode {
  
  let NAME: String = C_OBJ_NAME.boardCell
  var probability: CellProbabilityController!
  var delegate: BoardCellDelegate?
  // data
  let gridPoint: GridPoint!
  let board: Board!
  var mode = GameActionType.none { didSet { update() } }
  
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
  var probabilityIndicator: ProbabilityIndicator?
  var missIndicator: SCNNode?
  
  
  var floorColor: UIColor {
    return UIColor.fromHex("#34495e")
//    return probability.getFloorColor()
  }

  // MARK: ISers
  var isSpawnPoint: Bool = false { didSet { update() } }
  var isSpawnRegion: Bool = false { didSet { update() } }
  var isLabelVisible: Bool = false { didSet { update() } }
  var isHighlighted: Bool = false { didSet { update() } }
  var isMiss: Bool = false { didSet { update() } }
  
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
  
  
  init(_ column: Int, _ row: Int, board: Board) {
    self.gridPoint = GridPoint(column, row)
    self.board = board

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
    baseNode = ScnUtils.deepCopyNode(Models.boardCell)
    addChildNode(baseNode)
    
    floor = ScnUtils.getChildWithName(baseNode.childNodes, name: C_OBJ_NAME.cellFloor)

    selectableIndicator = ScnUtils.deepCopyNode(Models.selectableIndicator)
    selectableIndicator.opacity = 0.0
    addChildNode(selectableIndicator)
    
    selectableIndicator = ScnUtils.deepCopyNode(Models.selectableIndicator)
    selectableIndicator.opacity = 0.0
    addChildNode(selectableIndicator)
    
    update()
  }
  @discardableResult
  func attackCell() -> Bool {
    
    // note: we want to deal with collectables at some point
    
    if !hasAnyShip {
      isMiss = true
      return false
    } else {
      targetShipRef?.hitAt(gridPoint)
      return true
    }
  }
  
  // MARK: UPDATES
  func update() {
    updateFloor()
    updateLabel()
    updateHitNode()
    updateSelectableIndicator()
    updateMissIndicator()
  }
  func updateFloor() {
    floor?.geometry?.firstMaterial?.diffuse.contents = floorColor
  }
  func getFloorColor() -> UIColor {
    switch mode {
    case .move:
      return C_COLOR.lightBlue
    default:
      return UIColor.fromHex("#34495e")
    }
  }
  
  // MARK: SELECTION INDICATOR
  func updateSelectableIndicator() {
    switch mode {
    case .move, .probe, .shoot:
      showSelectableIndicator()
    default:
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
        gpLabel = ScnUtils.makeText(text: gridPoint.toString(),
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
    DispatchQueue.main.async {
//      if self.hasProbe {
//        self.showProbe()
//      } else {
//        self.hideProbe()
//      }
      
      self.updateProbabilityIndicator()
    }
  }
  func showProbe() {
    // already showing - bail
    guard probe == nil else { return }
    probe = Models.cellProbe.clone()
    addChildNode(probe!)
  }
  func hideProbe() {
    // not showing - bail
    guard probe != nil else { return }
    probe?.removeFromParentNode()
    probe = nil
  }
  
  
  // MARK: PROBABILITY INDICATOR
  func updateProbabilityIndicator() {
    if hasProbe {
      showProbabilityIndicator()
      // get new threats
      if let threats = delegate?.bcellGetSurroundingThreats(gridPoint) {
        probabilityIndicator?.threats = threats
      }
    } else {
      hideProbabilityIndicator()
    }
  }
  func showProbabilityIndicator() {
    // already showing - bail
    guard probabilityIndicator == nil else { return }
    probabilityIndicator = Models.probabilityIndicator

    addChildNode(probabilityIndicator!)
  }
  func hideProbabilityIndicator() {
    // not showing - bail
    guard probabilityIndicator != nil else { return }
    probabilityIndicator?.removeFromParentNode()
    probabilityIndicator = nil
  }
  
  
  // MARK: MISS INDICATOR
  func updateMissIndicator() {
    if isMiss {
      showMissIndicator()
    } else {
      hideMissIndicator()
    }
  }
  func showMissIndicator() {
    // already showing - bail
    guard missIndicator == nil else { return }
    missIndicator = Models.missIndicator

    addChildNode(missIndicator!)
  }
  func hideMissIndicator() {
    // not showing - bail
    guard missIndicator != nil else { return }
    missIndicator?.removeFromParentNode()
    missIndicator = nil

  }
}

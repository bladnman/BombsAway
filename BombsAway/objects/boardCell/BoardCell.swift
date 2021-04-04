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
enum BoardCellShotType {
  case none, miss, hit, sunk
}
class BoardCell: SCNNode {
  
  let NAME: String = C_OBJ_NAME.boardCell
  var probability: CellProbabilityController!
  var delegate: BoardCellDelegate?
  
  // data
  var boardStore: BoardStore
  let gridPoint: GridPoint!
  let board: Board!
  var mode = GameActionType.none { didSet { updateSelectableIndicator() } }
  
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
  var selectableIndicator: SCNNode?
  var probabilityIndicator: ProbabilityIndicator?
  var shotIndicator: SCNNode?
  
  
  var floorColor: UIColor {
    return UIColor.fromHex("#34495e")
//    return probability.getFloorColor()
  }
  var shotType: BoardCellShotType {
    if shotIndicator == nil {
      return .none
    }
    
    switch shotIndicator!.name {
      case C_OBJ_NAME.hitCoin: return .hit
      case C_OBJ_NAME.missIndicator: return .miss
      case C_OBJ_NAME.sunkCoin: return .sunk
      default: return .none
    }
  }

  // MARK: ISers
  var isSpawnPoint: Bool = false { didSet { update() } }
  var isSpawnRegion: Bool = false { didSet { update() } }
  var isLabelVisible: Bool = false { didSet { update() } }
  var isHighlighted: Bool = false { didSet { update() } }
  var isMiss: Bool = false { didSet { update() } }
  
  var shipData: ShipData? { boardStore.getShipAtGridpoint(gridPoint) }
  var hasSolidShip: Bool {
    return shipData != nil &&
      shotType != .hit &&
      shotType != .sunk
  }
  var hasAnyShip: Bool { shipData != nil }
  var isClearForShipPlacement: Bool { !hasAnyShip && !isSpawnRegion }
  var isClearForMovement: Bool { !hasSolidShip }
  var hasCollectible: Bool = false
  var hasProbe: Bool = false {
    didSet {
      updateProbe()
    }
  }
//  var hasShot: Bool { boardStore.shots.contains(where: {$0.gridPoint == gridPoint}) }
  
  init(_ column: Int, _ row: Int, board: Board, boardStore: BoardStore) {
    self.gridPoint = GridPoint(column, row)
    self.board = board
    self.boardStore = boardStore

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

    DispatchQueue.main.async {
      self.update()
    }
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
    updateSelectableIndicator()
    
    updateProbeFromBoardStore()
    updateShotFromBoardStore()
    
  }
  func updateProbeFromBoardStore() {
    hasProbe = boardStore.probes.contains(where: {$0.gridPoint == gridPoint})
  }
  func updateShotFromBoardStore() {
    let hasShot = boardStore.shots.contains(where: {$0.gridPoint == gridPoint})
    if hasShot == true {
      updateShotIndicator()
    }
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
    if selectableIndicator == nil {
      selectableIndicator = Models.selectableIndicator
      
      if let selectableIndicator = self.selectableIndicator {
        selectableIndicator.opacity = 0.0
        addChildNode(selectableIndicator)
        
        let fadeAction = SCNAction.fadeIn(duration: duration)
        fadeAction.timingMode = .easeInEaseOut
        selectableIndicator.runAction(fadeAction, forKey: "fadeIn")
      }
    }

  }
  func hideSelectableIndicator(_ duration: Double = C_MOVE.BoardCell.SelectIndicator.fadeOutSec) {
    selectableIndicator?.removeAction(forKey: "fadeIn")
    
    let fadeAction = SCNAction.fadeOut(duration: duration)
    fadeAction.timingMode = .easeOut
    
    selectableIndicator?.runAction(fadeAction, forKey: "fadeOut") {
      self.selectableIndicator?.removeFromParentNode()
      self.selectableIndicator = nil
    }
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
  
  
  // MARK: SHOT INDICATOR
  func updateShotIndicator() {
    
    var finalShotMode: BoardCellShotType = .none
    
    // SHIP!
    if hasAnyShip {
      finalShotMode = boardStore.isShipSunk(shipData) ? .sunk : .hit
    }
    
    // NO SHIP
    else {
      finalShotMode = .miss
    }

    // MAKE SURE THERE IS A CHANGE
    if finalShotMode != shotType {
      shotIndicator?.removeFromParentNode()
      
      switch finalShotMode {
      case .miss: shotIndicator = Models.missIndicator
      case .hit: shotIndicator = Models.blueCoin
      case .sunk: shotIndicator = Models.redCoin
      default: shotIndicator = nil
      }
      
      if shotIndicator != nil {
        addChildNode(shotIndicator!)
      }
    }
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
  

}

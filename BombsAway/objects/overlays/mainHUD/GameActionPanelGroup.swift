//
//  TurnPanel.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/21/21.
//

import SpriteKit


protocol GameActionPanelGroupDelegate {
  func gameActionPanelGroupHandledTouchStart()
  func gameActionPanelGroupHandledTouchEnd()
  
  func gameActionPanelGroupMovePressed()
  func gameActionPanelGroupProbePressed()
  func gameActionPanelGroupShootPressed()
}
class GameActionPanelGroup: SKNode {
  
  var delegate: GameActionPanelGroupDelegate?
  
  var isHandlingTouch = false {
    didSet {
      // trying to not message twice
      // or when we were not handling touches to begin with
      if isHandlingTouch {
        if !oldValue {
          delegate?.gameActionPanelGroupHandledTouchStart()
        }
      } else {
        if oldValue {
          delegate?.gameActionPanelGroupHandledTouchEnd()
        }
      }
    }
  }
  var boundingBoxNode: SKShapeNode?
  override var frame: CGRect { boundingBoxNode?.frame ?? CGRect.zero }

  convenience init(delegate: GameActionPanelGroupDelegate) {
    self.init()
    self.delegate = delegate
  }
  override init() {
    super.init()
    self.isUserInteractionEnabled = true
    
    createPanels()
  }
  func createPanels() {
    let panelCount = CGFloat(C_PLAYER.startingActionsPerTurn)
    
    var turnPanel = GameActionPanel() // first one is for size only
    let overlap = CGFloat(10.0)
    let panelWidth = turnPanel.frame.size.width
    let fullWidth = (panelCount * panelWidth) - (overlap * panelCount - 1)
    let centerX = fullWidth / 2
    let xStart = (-1*centerX) + (panelWidth/2)
    
    for i in 0...(Int(panelCount) - 1) {
      turnPanel = GameActionPanel(delegate: self)
      let panelOverlap = CGFloat(i) * overlap
      let x = floor(xStart + (CGFloat(i) * panelWidth) - panelOverlap)
      let pos = CGPoint(x: x , y: 0.0)
      turnPanel.position = pos
      addChild(turnPanel)
    }
   
    updateBoundingBox()
  }
  func update() {
    
  }
  func updateBoundingBox() {
    self.boundingBoxNode = SKShapeNode(rectOf: self.calculateAccumulatedFrame().size)
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

extension GameActionPanelGroup: GameActionPanelDelegate {
  func gameActionPanelHandledTouchStart(_ panel: GameActionPanel) {
    delegate?.gameActionPanelGroupHandledTouchStart()
  }
  
  func gameActionPanelHandledTouchEnd(_ panel: GameActionPanel) {
    delegate?.gameActionPanelGroupHandledTouchEnd()
  }
  
  func gameActionPanelMovePressed(_ panel: GameActionPanel) {
    delegate?.gameActionPanelGroupMovePressed()
    panel.actionType = .move
  }
  
  func gameActionPanelProbePressed(_ panel: GameActionPanel) {
    delegate?.gameActionPanelGroupProbePressed()
    panel.actionType = .probe
  }
  
  func gameActionPanelShootPressed(_ panel: GameActionPanel) {
    delegate?.gameActionPanelGroupShootPressed()
    panel.actionType = .shoot
  }
}

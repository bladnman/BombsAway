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
  var gameStore: GameStore
  var playerStore: PlayerStore
  var delegate: GameActionPanelGroupDelegate
  var isHandlingTouch = false {
    didSet {
      // trying to not message twice
      // or when we were not handling touches to begin with
      if isHandlingTouch {
        if !oldValue {
          delegate.gameActionPanelGroupHandledTouchStart()
        }
      } else {
        if oldValue {
          delegate.gameActionPanelGroupHandledTouchEnd()
        }
      }
    }
  }
  var boundingBoxNode: SKShapeNode?
  var panelCount: Int  = 0
  
  override var frame: CGRect { boundingBoxNode?.frame ?? CGRect.zero }

  init(gameStore: GameStore, playerStore: PlayerStore, delegate: GameActionPanelGroupDelegate) {
    self.delegate = delegate
    self.gameStore = gameStore
    self.playerStore = playerStore
    
    super.init()
    
    self.isUserInteractionEnabled = true
    
    createPanels()
  }
  func createPanels() {
    
    panelCount = playerStore.actionsPerTurn
    let panelCountFloat = CGFloat(panelCount)
    
    var turnPanel = GameActionPanel() // first one is for size only
    let overlap = CGFloat(10.0)
    let panelWidth = turnPanel.frame.size.width
    let fullWidth = (panelCountFloat * panelWidth) - (overlap * panelCountFloat - 1)
    let centerX = fullWidth / 2
    let xStart = (-1*centerX) + (panelWidth/2)
    
    for i in 0...(Int(panelCountFloat) - 1) {
      
      // see if there is an action type for this index in the current turn
      turnPanel = GameActionPanel(delegate: self, actionType: getActionTypeForIndex(i))
      let panelOverlap = CGFloat(i) * overlap
      let x = floor(xStart + (CGFloat(i) * panelWidth) - panelOverlap)
      let pos = CGPoint(x: x , y: 0.0)
      turnPanel.position = pos
      turnPanel.name = C_OBJ_NAME.actionPanel
      addChild(turnPanel)
    }
   
    updateBoundingBox()
  }
  func removePanels() {
    self.enumerateChildNodes(withName: C_OBJ_NAME.actionPanel) { (node, _) in
      node.removeFromParent()
    }
  }
  func update() {
    // has panel count changed? Yes?
    if panelCount != playerStore.actionsPerTurn {
      removePanels()
      createPanels()
    }
    
    // same panel count, update instead
    else {
      for idx in 0...children.count-1 {
        let child = children[idx]
        
        switch child {
        case let panel as GameActionPanel:
          panel.actionType = getActionTypeForIndex(idx)
        default:
          break
        }
        
      }
    }
    

  }
  func updateBoundingBox() {
    self.boundingBoxNode = SKShapeNode(rectOf: self.calculateAccumulatedFrame().size)
  }
  
  
  // helpers
  func getActionTypeForIndex(_ index:Int) -> GameActionType {
    
    if let actionAtIndex = gameStore.currentTurn.actionForIndex(index) {
      return actionAtIndex.type
    }
    
    return .none
    
  }
  
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

extension GameActionPanelGroup: GameActionPanelDelegate {
  func gameActionPanelHandledTouchStart(_ panel: GameActionPanel) {
    delegate.gameActionPanelGroupHandledTouchStart()
  }
  func gameActionPanelHandledTouchEnd(_ panel: GameActionPanel) {
    delegate.gameActionPanelGroupHandledTouchEnd()
  }
  func gameActionPanelMovePressed(_ panel: GameActionPanel) {
    delegate.gameActionPanelGroupMovePressed()
    panel.actionType = .move
  }
  func gameActionPanelProbePressed(_ panel: GameActionPanel) {
    delegate.gameActionPanelGroupProbePressed()
    panel.actionType = .probe
  }
  func gameActionPanelShootPressed(_ panel: GameActionPanel) {
    delegate.gameActionPanelGroupShootPressed()
    panel.actionType = .shoot
  }
}

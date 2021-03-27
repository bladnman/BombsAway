//
//  MainHUD.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/20/21.
//

import SpriteKit
protocol MainHUDProtocol {
  func mainHUDHandledTouchStart()
  func mainHUDHandledTouchEnd()
  func mainHUDMovePressed()
  func mainHUDProbePressed()
  func mainHUDShootPressed()
}
class MainHUD: SKScene {
  var hudDelegate: MainHUDProtocol?
  var nameLabel = SKLabelNode(fontNamed: "8BIT WONDER Nominal")
  var healthNode = AttackShipHealth()
  var isHandlingTouch = false {
    didSet {
      // trying to not message twice
      // or when we were not handling touches to begin with
      if isHandlingTouch {
        if !oldValue {
          hudDelegate?.mainHUDHandledTouchStart()
        }
      } else {
        if oldValue {
          hudDelegate?.mainHUDHandledTouchEnd()
        }
      }
    }
  }
  var player: Player? { didSet { update() }}
  
  // MARK: MAIN FOR NOW
  convenience init(size:CGSize, delegate:MainHUDProtocol) {
    self.init(size: size)
    self.isUserInteractionEnabled = true
    self.hudDelegate = delegate
    setup()
  }
  func setup() {
    addGameActionPanelGroup()
    addPlayerHealth()
    addPlayerName()
    
    update()
  }
  func update() {
    if let player = self.player {
      // update player name
      nameLabel.text = player.name
      
      // update health
      healthNode.health = player.hitPoints
      healthNode.maxHealth = player.hitPointsMax
      
    }
    
    
  }
  func addPlayerHealth() {
    addChild(healthNode)
    let hWidth = healthNode.frame.size.width
    let hHeight = healthNode.frame.size.height
    healthNode.position = CGPoint(x: size.width - 50.0 - hWidth/2, y: 50.0 + hHeight/2)
  }
  func addGameActionPanelGroup() {
    let allPanelsNode = GameActionPanelGroup(delegate: self);
    let x:CGFloat = frame.midX
    let y:CGFloat = allPanelsNode.frame.size.height/2 + 20.0
    allPanelsNode.position = CGPoint(x: x, y: y)
    addChild(allPanelsNode)
    allPanelsNode.setScale(0.7)
  }
  func addPlayerName() {
    nameLabel.text = "player name"
    nameLabel.fontSize = 15.0
    addChild(nameLabel)
    
    let hHeight = healthNode.frame.size.height
    nameLabel.position = CGPoint(x: healthNode.position.x, y: healthNode.position.y + hHeight)
  }
}

extension MainHUD {
  // MARK: TOUCHES
  func handleTouches(_ touches: Set<UITouch>, for touchPhase: TouchPhase) {
//    for touch: AnyObject in touches {
//      let location = touch.location(in: self)
//      if redBox == self.atPoint(location) {
//        print("redBox Touch event")
//      }
//    }
    isHandlingTouch = touchPhase == .start
  }
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    handleTouches(touches, for: .start)
  }
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    handleTouches(touches, for: .end)
  }
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    handleTouches(touches, for: .end)
  }
}
extension MainHUD: GameActionPanelGroupDelegate {
  // MARK: GAME ACTION PANEL GROUP DELEGATE
  func gameActionPanelGroupMovePressed() {
    hudDelegate?.mainHUDMovePressed()
  }
  func gameActionPanelGroupProbePressed() {
    hudDelegate?.mainHUDProbePressed()
  }
  func gameActionPanelGroupShootPressed() {
    hudDelegate?.mainHUDShootPressed()
  }
  
  func gameActionPanelGroupHandledTouchStart() {
    isHandlingTouch = true
  }
  func gameActionPanelGroupHandledTouchEnd() {
    isHandlingTouch = false
  }
}

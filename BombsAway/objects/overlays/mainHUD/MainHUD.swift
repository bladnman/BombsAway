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
  var redBox: SKNode!
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
  }
  func addPlayerHealth() {
    let health = PlayerShipHealth()
    addChild(health)
    let hWidth = health.frame.size.width
    let hHeight = health.frame.size.height
    health.position = CGPoint(x: size.width - 50.0 - hWidth/2, y: 50.0 + hHeight/2)
  }
  func addGameActionPanelGroup() {
    let allPanelsNode = GameActionPanelGroup(delegate: self);
    let x:CGFloat = (CGFloat(size.width) * 0.5)
    let y:CGFloat = allPanelsNode.frame.size.height/2 + 20.0
    allPanelsNode.position = CGPoint(x: x, y: y)
    addChild(allPanelsNode)
    allPanelsNode.setScale(0.7)
  }
}

extension MainHUD {
  // MARK: TOUCHES
  func handleTouches(_ touches: Set<UITouch>, for touchPhase: TouchPhase) {
    for touch: AnyObject in touches {
      let location = touch.location(in: self)
      if redBox == self.atPoint(location) {
        print("redBox Touch event")
      }
    }
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

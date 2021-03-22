//
//  MainHUD.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/20/21.
//

import SpriteKit
protocol OverlayProtocol {
  func overlayHandledTouchStart()
  func overlayHandledTouchEnd()
}
class MainHUD: SKScene {

  

  var overlayDelegate: OverlayProtocol?
  var redBox: SKNode!
  var isHandlingTouch = false {
    didSet {
      // trying to not message twice
      // or when we were not handling touches to begin with
      if isHandlingTouch {
        if !oldValue {
          overlayDelegate?.overlayHandledTouchStart()
        }
      } else {
        if oldValue {
          overlayDelegate?.overlayHandledTouchEnd()
        }
      }
    }
  }
  
  
  // MARK: MAIN FOR NOW
  convenience init(size:CGSize, overlayDelegate:OverlayProtocol) {
    self.init(size: size)
    self.isUserInteractionEnabled = true
    self.overlayDelegate = overlayDelegate
    setup()
  }
  func setup() {
    redBox = SKSpriteNode(color: UIColor.red, size: CGSize(width: 200, height: 100))
    self.addChild(redBox)
    redBox.position = CGPoint(x: size.width/2, y: size.height/1.5)
    
    let btn = LabelButton(text: "Morning World", size: CGSize(width: 150, height: 75), action: handleButtonPress, index: 1)
    self.addChild(btn)
    btn.position = CGPoint(x: size.width/2, y: size.height/3)
    btn.onUp = handleButtonUp
    btn.onDown = handleButtonDown
    
    addTurnPanels()
    addPlayerHealth()
  }
  func addPlayerHealth() {
    let health = PlayerShipHealth()
    addChild(health)
    let hWidth = health.frame.size.width
    let hHeight = health.frame.size.height
    health.position = CGPoint(x: size.width - 50.0 - hWidth/2, y: 50.0 + hHeight/2)
  }
  func addTurnPanels() {
    let allPanelsNode = SKNode();
    var panelHeight: CGFloat = 0.0
    for i in 0...2 {
      print("[M@] [\(i)]")
      let turnPanel = TurnPanel(delegate: self)
      turnPanel.position = CGPoint(x: (CGFloat(i) * turnPanel.frame.size.width) - CGFloat(i) * 10.0, y: 0.0)
      allPanelsNode.addChild(turnPanel)
      
      panelHeight = turnPanel.frame.size.height
    }
    let x:CGFloat = (CGFloat(size.width) * 0.5)
    let y:CGFloat = panelHeight/2 + 20.0
    allPanelsNode.position = CGPoint(x: x, y: y)
    addChild(allPanelsNode)
    allPanelsNode.setScale(0.7)
  }

  func handleButtonPress(buttonIndex: Int) {
    print("[M@] [\(buttonIndex)] was pressed")
    isHandlingTouch = false
  }
  func handleButtonUp(buttonIndex: Int) {
    print("[M@] [\(buttonIndex)] was pushed up")
    isHandlingTouch = true
  }
  func handleButtonDown(buttonIndex: Int) {
    print("[M@] [\(buttonIndex)] was pushed down")
    isHandlingTouch = true
  }
  
  
  
  
  // MARK: RUNAWAY THREAD
  // hold on to this code
  // some odd runaway thread happening here
  //
//  convenience init(overlayDelegate: OverlayProtocol) {
//    self.init()
//    self.overlayDelegate = overlayDelegate
//  }
//  override convenience init() {
//    self.init(fileNamed: "MainHUD")!
//    self.isUserInteractionEnabled = true
//
//    if let redBox = childNode(withName: "RED_BOX") {
//      self.redBox = redBox
//    }
//  }
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

extension MainHUD: TurnPanelDelegate {
  // MARK: TURN PANEL DELEGATE
  func turnPanelMovePressed(_ panel: TurnPanel) {
    print("[M@] handleMovePress")
    panel.mode = .move
  }
  func turnPanelProbePressed(_ panel: TurnPanel) {
    print("[M@] handleProbePress")
    panel.mode = .probe
  }
  func turnPanelShootPressed(_ panel: TurnPanel) {
    print("[M@] handleShootPress")
    panel.mode = .shoot
  }
  func turnPanelHandledTouchStart(_ panel: TurnPanel) {
    isHandlingTouch = true
  }
  func turnPanelHandledTouchEnd(_ panel: TurnPanel) {
    isHandlingTouch = false
  }
}

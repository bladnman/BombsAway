//
//  TurnPanel.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/21/21.
//

import SpriteKit

let iconPadding:CGFloat = 20.0

protocol GameActionPanelDelegate {
  func gameActionPanelHandledTouchStart(_ panel: GameActionPanel)
  func gameActionPanelHandledTouchEnd(_ panel: GameActionPanel)
  
  func gameActionPanelMovePressed(_ panel: GameActionPanel)
  func gameActionPanelProbePressed(_ panel: GameActionPanel)
  func gameActionPanelShootPressed(_ panel: GameActionPanel)
}
class GameActionPanel: SKNode {
  
  let background: SKShapeNode!
  let moveIcon: SKSpriteNode!
  let probeIcon: SKSpriteNode!
  let shootIcon: SKSpriteNode!
  let canceledIcon: SKSpriteNode!
  var delegate: GameActionPanelDelegate?
  
  var actionType: GameActionType = .none { didSet { update() }}
  var isHandlingTouch = false {
    didSet {
      // trying to not message twice
      // or when we were not handling touches to begin with
      if isHandlingTouch {
        if !oldValue {
          delegate?.gameActionPanelHandledTouchStart(self)
        }
      } else {
        if oldValue {
          delegate?.gameActionPanelHandledTouchEnd(self)
        }
      }
    }
  }
  
  let fullSize: CGFloat
  var halfSize: CGFloat { fullSize/2 }
  override var frame: CGRect { background.frame }

  convenience init(delegate: GameActionPanelDelegate, actionType: GameActionType = .none) {
    self.init()
    self.delegate = delegate
    self.actionType = actionType
    update()
  }
  override init() {
    self.moveIcon = SKSpriteNode(imageNamed: "art.scnassets/move icon")
    self.probeIcon = SKSpriteNode(imageNamed: "art.scnassets/probe icon")
    self.shootIcon = SKSpriteNode(imageNamed: "art.scnassets/shoot icon")
    self.canceledIcon = SKSpriteNode(imageNamed: "art.scnassets/not icon")
    fullSize = moveIcon.size.width
    let halfSize = fullSize/2

    let size = CGSize(width: halfSize + CGFloat(iconPadding*4),
                      height: halfSize*3 + CGFloat(iconPadding*4))
    
    self.background = SKShapeNode(rect: CGRect(origin: CGPoint.zero, size: size) )
    background.fillColor = C_COLOR.blue
    background.strokeColor = C_COLOR.lightBlue
    background.lineWidth = 3.0
    background.position = CGPoint(x: -1*size.width/2, y: -1*size.height/2)

    super.init()
    self.isUserInteractionEnabled = true
    
    addChild(background)
    addChild(moveIcon)
    addChild(probeIcon)
    addChild(shootIcon)
    addChild(canceledIcon)
    update()
  }
  func update() {
    switch actionType {
    case .none:
      setUntakenLayout()
    default:
      setTakenLayout()
    }
  }
  func setUntakenLayout() {
    moveIcon.alpha = 1.0
    probeIcon.alpha = 1.0
    shootIcon.alpha = 1.0
    canceledIcon.alpha = 0.0
    
    moveIcon.position = CGPoint(x: 0.0, y: (halfSize) + iconPadding)
    probeIcon.position = CGPoint(x:0.0, y: 0.0)
    shootIcon.position = CGPoint(x:0.0, y: (halfSize * -1) - iconPadding)
    
    moveIcon.scale(to: CGSize(width: halfSize, height: halfSize))
    probeIcon.scale(to: CGSize(width: halfSize, height: halfSize))
    shootIcon.scale(to: CGSize(width: halfSize, height: halfSize))
    
    background.alpha = 1.0
  }
  func setTakenLayout() {
    moveIcon.alpha = 0.0
    probeIcon.alpha = 0.0
    shootIcon.alpha = 0.0
    canceledIcon.alpha = 0.0
    
    var icon = moveIcon
    switch actionType {
    case .move: icon = moveIcon
    case .probe: icon = probeIcon
    case .shoot: icon = shootIcon
    case .canceled: icon = canceledIcon
    case .none: break
    }
    
    icon?.position = CGPoint.zero
    icon?.scale(to: CGSize(width: fullSize, height: fullSize))
    icon?.alpha = actionType == GameActionType.canceled ? 0.3 : 0.7
    background.alpha = 0.7
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: TOUCHES
  func handleTouches(_ touches: Set<UITouch>, for touchPhase: TouchPhase) {
    // for ENDING touches (and only when untaken)
    if touchPhase == .end && actionType == .none {
      for touch: AnyObject in touches {
        let location = touch.location(in: self)
        if moveIcon == self.atPoint(location) {
          delegate?.gameActionPanelMovePressed(self)
        }
        else if probeIcon == self.atPoint(location) {
          delegate?.gameActionPanelProbePressed(self)
        }
        else if shootIcon == self.atPoint(location) {
          delegate?.gameActionPanelShootPressed(self)
        }
      }
    }
    
    // always last
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

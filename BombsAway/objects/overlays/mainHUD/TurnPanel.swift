//
//  TurnPanel.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/21/21.
//

import SpriteKit

let iconPadding:CGFloat = 20.0

enum TurnMode {
  case untaken, shoot, probe, move
}
protocol TurnPanelDelegate {
  func turnPanelHandledTouchStart(_ panel: TurnPanel)
  func turnPanelHandledTouchEnd(_ panel: TurnPanel)
  
  func turnPanelMovePressed(_ panel: TurnPanel)
  func turnPanelProbePressed(_ panel: TurnPanel)
  func turnPanelShootPressed(_ panel: TurnPanel)
}
class TurnPanel: SKNode {
  
  let background: SKShapeNode!
  let moveIcon: SKSpriteNode!
  let probeIcon: SKSpriteNode!
  let shootIcon: SKSpriteNode!
  var delegate: TurnPanelDelegate?
  
  var onMovePressed: (() -> Void)?
  var onProbePressed: (() -> Void)?
  var onShootPressed: (() -> Void)?
  
  var mode: TurnMode = .untaken { didSet { update() }}
  var isHandlingTouch = false {
    didSet {
      // trying to not message twice
      // or when we were not handling touches to begin with
      if isHandlingTouch {
        if !oldValue {
          delegate?.turnPanelHandledTouchStart(self)
        }
      } else {
        if oldValue {
          delegate?.turnPanelHandledTouchEnd(self)
        }
      }
    }
  }
  
  let fullSize: CGFloat
  var halfSize: CGFloat { fullSize/2 }
  override var frame: CGRect { background.frame }

  convenience init(delegate: TurnPanelDelegate) {
    self.init()
    self.delegate = delegate
  }
  override init() {
    self.moveIcon = SKSpriteNode(imageNamed: "art.scnassets/move icon")
    self.probeIcon = SKSpriteNode(imageNamed: "art.scnassets/probe icon")
    self.shootIcon = SKSpriteNode(imageNamed: "art.scnassets/shoot icon")
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
    update()
  }
  func update() {
    switch mode {
    case .untaken:
      setUntakenLayout()
    default:
      setTakenLayout()
    }
  }
  func setUntakenLayout() {
    moveIcon.alpha = 1.0
    probeIcon.alpha = 1.0
    shootIcon.alpha = 1.0
    
    moveIcon.position = CGPoint(x: 0.0, y: (halfSize) + iconPadding)
    probeIcon.position = CGPoint(x:0.0, y: 0.0)
    shootIcon.position = CGPoint(x:0.0, y: (halfSize * -1) - iconPadding)
    
    moveIcon.scale(to: CGSize(width: halfSize, height: halfSize))
    probeIcon.scale(to: CGSize(width: halfSize, height: halfSize))
    shootIcon.scale(to: CGSize(width: halfSize, height: halfSize))
  }
  func setTakenLayout() {
    moveIcon.alpha = 0.0
    probeIcon.alpha = 0.0
    shootIcon.alpha = 0.0
    
    var icon = moveIcon
    switch mode {
    case .move: icon = moveIcon
    case .probe: icon = probeIcon
    case .shoot: icon = shootIcon
    default: break
    }
    
    icon?.position = CGPoint.zero
    icon?.scale(to: CGSize(width: fullSize, height: fullSize))
    icon?.alpha = 0.7
    background.alpha = 0.7
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: TOUCHES
  func handleTouches(_ touches: Set<UITouch>, for touchPhase: TouchPhase) {
    // for ENDING touches (and only when untaken)
    if touchPhase == .end && mode == .untaken {
      for touch: AnyObject in touches {
        let location = touch.location(in: self)
        if moveIcon == self.atPoint(location) {
          delegate?.turnPanelMovePressed(self)
          onMovePressed?()
        }
        else if probeIcon == self.atPoint(location) {
          delegate?.turnPanelProbePressed(self)
          onProbePressed?()
        }
        else if shootIcon == self.atPoint(location) {
          delegate?.turnPanelShootPressed(self)
          onShootPressed?()
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

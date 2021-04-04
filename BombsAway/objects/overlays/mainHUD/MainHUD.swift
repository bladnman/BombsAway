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
  func mainHUDHealthPressed()
  func mainHUDMoveToNextPlayerPressed()
  func mainHUDHandoffCompletePressed()
}
enum MainHUDState {
  case turn, endOfTurn, handoff, victory
}
let marginHoriz: CGFloat = 50
let marginVert: CGFloat = 50
class MainHUD: SKScene {
  var hudDelegate: MainHUDProtocol?
  var nameLabel: SKLabelNode?
  var healthNode: AttackShipHealth?
  var overlay: SKNode?
  var gameActionPanelGroup: GameActionPanelGroup?
  var state: MainHUDState = .turn { didSet { setup() } }
  
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
  var gameStore: GameStore { didSet { setup() }}
  var playerStore: PlayerStore { didSet { setup() }}
  
  // MARK: MAIN FOR NOW
  init(gameStore: GameStore, playerStore: PlayerStore, size:CGSize, delegate:MainHUDProtocol) {
    
    self.playerStore = playerStore
    self.gameStore = gameStore
    
    super.init(size: size)
    self.isUserInteractionEnabled = true
    self.hudDelegate = delegate
    
    self.setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  func setup() {
    DispatchQueue.main.async {
      self.removeAllChildren()
      switch self.state {
      case .turn:
        self.setupForTurn()
      case .endOfTurn:
        self.setupForEndOfTurn()
      case .handoff:
        self.setupForHandoff()
      case .victory:
        self.setupForVictory()
      }
      
      self.update()
    }
  }
  func setupForTurn() {
    addGameActionPanelGroup()
    addPlayerHealth()
    addPlayerName()
  }
  func setupForEndOfTurn() {
    addOverlay()
    addPlayerHealth()
    addPlayerName()
    addEndOfTurnButton()
  }
  func setupForHandoff() {
    addOverlay()
    addHandoffButton()
  }
  func setupForVictory() {
    addOverlay()
    addVictoryButton()
  }
  
  func update() {
    let playerStore = self.playerStore
    
    // update health
    if let healthNode = self.healthNode {
      healthNode.health = playerStore.hitPoints
      healthNode.maxHealth = playerStore.hitPointsMax
    }
    
    gameActionPanelGroup?.update()
  }
  func addPlayerHealth() {
    healthNode = AttackShipHealth()
    if let healthNode = self.healthNode {
      healthNode.name = "healthNode"
      addChild(healthNode)
      let hWidth = healthNode.frame.size.width
      let hHeight = healthNode.frame.size.height
      healthNode.position = CGPoint(x: size.width - marginHoriz - hWidth/2, y: marginVert + hHeight/2)
    }
  }
  func addGameActionPanelGroup() {
    gameActionPanelGroup = GameActionPanelGroup(gameStore: gameStore, playerStore: playerStore, delegate: self);
    let x:CGFloat = frame.midX
    let y:CGFloat = gameActionPanelGroup!.frame.size.height/2 + 20.0
    gameActionPanelGroup!.position = CGPoint(x: x, y: y)
    addChild(gameActionPanelGroup!)
    gameActionPanelGroup!.setScale(0.7)
  }
  func addPlayerName() {
    nameLabel = SKLabelNode(fontNamed: "8BIT WONDER Nominal")
    if let nameLabel = self.nameLabel {
      nameLabel.text = playerStore.name
      nameLabel.fontSize = 15.0
      addChild(nameLabel)
      
      let hHeight = healthNode?.frame.size.height ?? 0
      let hX = healthNode != nil ? healthNode!.position.x : marginHoriz
      let hY = healthNode != nil ? healthNode!.position.y : marginVert
      nameLabel.position = CGPoint(x: hX, y: hY + hHeight)
    }
    
  }
  func addEndOfTurnButton() {
    
    let turnOverLabel = SKLabelNode(fontNamed: "8BIT WONDER Nominal")
    turnOverLabel.text = "Turn Over"
    turnOverLabel.fontSize = 30.0
    addChild(turnOverLabel)
    turnOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
    
    let nextPlayerNameLabel = SKLabelNode(fontNamed: "8BIT WONDER Nominal")
    nextPlayerNameLabel.text = "Up next: " + (gameStore.nextTurnPlayerStore?.name ?? "")
    nextPlayerNameLabel.fontSize = 20.0
    addChild(nextPlayerNameLabel)
    nextPlayerNameLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 40.0)
    
    func handlePress(_ buttonIndex: Int) {
      DispatchQueue.main.async {
        self.hudDelegate?.mainHUDMoveToNextPlayerPressed()
      }
    }
    
    let button = LabelButton(text: "Understood", size: CGSize(width: 250.0, height: 100), action: handlePress, index: 0)
    button.color = C_COLOR.green
    addChild(button)
    button.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 200.0)
    
  }
  func addHandoffButton() {
    let turnOverLabel = SKLabelNode(fontNamed: "8BIT WONDER Nominal")
    turnOverLabel.text = "HANDOFF"
    turnOverLabel.fontSize = 50.0
    addChild(turnOverLabel)
    turnOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
    
    let nextPlayerNameLabel = SKLabelNode(fontNamed: "8BIT WONDER Nominal")
    nextPlayerNameLabel.text = "Pass device to: " + (gameStore.nextTurnPlayerStore?.name ?? "")
    nextPlayerNameLabel.fontSize = 30.0
    addChild(nextPlayerNameLabel)
    nextPlayerNameLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 60.0)
    
    func handlePress(_ buttonIndex: Int) {
      DispatchQueue.main.async {
        self.hudDelegate?.mainHUDHandoffCompletePressed()
      }
    }
    
    let button = LabelButton(text: "Start My Turn", size: CGSize(width: 250.0, height: 100), action: handlePress, index: 0)
    button.color = C_COLOR.green
    addChild(button)
    button.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 300.0)
    
  }
  func addVictoryButton() {
    let turnOverLabel = SKLabelNode(fontNamed: "8BIT WONDER Nominal")
    turnOverLabel.text = "W I N N E R"
    turnOverLabel.fontSize = 50.0
    addChild(turnOverLabel)
    turnOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
    
    let nextPlayerNameLabel = SKLabelNode(fontNamed: "8BIT WONDER Nominal")
    nextPlayerNameLabel.text = gameStore.currentTurnPlayerStore?.name ?? "unknown"
    nextPlayerNameLabel.fontSize = 30.0
    addChild(nextPlayerNameLabel)
    nextPlayerNameLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 60.0)
    
//    func handlePress(_ buttonIndex: Int) {
//      hudDelegate?.mainHUDHandoffCompletePressed()
//    }
//
//    let button = LabelButton(text: "Play Again", size: CGSize(width: 250.0, height: 100), action: handlePress, index: 0)
//    button.color = C_COLOR.green
//    addChild(button)
//    button.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 300.0)
    
  }
  func addOverlay() {
    overlay?.removeFromParent()
    
    let overlayNode = SKShapeNode(rect: CGRect(origin: CGPoint.zero, size: size) )
    overlayNode.fillColor = UIColor.black
    overlayNode.alpha = 0.7
    overlayNode.zPosition = -1
    addChild(overlayNode)
    
    self.overlay = overlayNode
  }
}

extension MainHUD {
  // MARK: TOUCHES
  func handleTouches(_ touches: Set<UITouch>, for touchPhase: TouchPhase) {
    isHandlingTouch = touchPhase == .start
  }
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    handleTouches(touches, for: .start)
    
    for touch: AnyObject in touches {
      let location = touch.location(in: self)
      let touchedNode = self.atPoint(location)
      
      // some parent is health node
      if SKUtils.getAncestorWithName(touchedNode, name: "healthNode") != nil {
        hudDelegate?.mainHUDHealthPressed()
      }
    }
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

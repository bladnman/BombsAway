//
//  PlayerShipHealth.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/21/21.
//

import SpriteKit
import Foundation

class PlayerShipHealth: SKNode {
  var maxHealth = C_PLAYER.startingHealth { didSet { update() } }
  var health = C_PLAYER.startingHealth { didSet { update() } }
  
  let cropNode = SKCropNode()
  let fillNode: SKSpriteNode!
  
  override var frame: CGRect { cropNode.maskNode!.frame }
  
  override init() {
    cropNode.maskNode = SKSpriteNode(imageNamed: "art.scnassets/player ship")
    let size = cropNode.maskNode!.frame.size
    fillNode = SKSpriteNode(color: C_COLOR.lightBlue, size: size)
    cropNode.addChild(fillNode)
    
    super.init()

    // add a bg transparent node of the ship
    let bgNode = SKSpriteNode(imageNamed: "art.scnassets/player ship")
    bgNode.color = C_COLOR.red
    bgNode.colorBlendFactor = 1.0
    
    addChild(bgNode)
    addChild(cropNode)
    
    update()
  }
  func update() {
    let percentage = CGFloat(health) / CGFloat(maxHealth)
    
    // move fill node "away" (off left)
    // for lower percentages
    let newX = -1 * (frame.size.width - frame.size.width * percentage)
    fillNode.position = CGPoint(x: newX, y: 0)
  }
  
  
  
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

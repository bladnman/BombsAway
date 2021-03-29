//
//  PlayerNode.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/8/21.
//

import SceneKit

class AttackShip: SCNNode {
  let NAME = C_OBJ_NAME.player
  let player: Player!
  
  // calculateds
  var gridPoint: GridPoint { GridPoint(Int(position.x), Int(position.z)) }
  
  init(player: Player) {
    self.player = player
    super.init()
    self.name = NAME
    self.addChildNode(Models.attackShip.clone())
  }
  
  func takeAHit() {
    // the player was hit... reduce HP
    player.hitPoints -= 1
    
    // MARK: SHIP DIED
    if player.isDead {
      animateDeath()
    }
  }
  func animateDeath() {
    let fadeAction = SCNAction.fadeOut(duration: 1.5)
    runAction(fadeAction)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

//
//  PlayerNode.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/8/21.
//

import SceneKit

class AttackShip: SCNNode {
  let NAME = C_OBJ_NAME.player
  let playerStore: PlayerStore
  
  // calculateds
  var gridPoint: GridPoint { GridPoint(Int(position.x), Int(position.z)) }
  
  init(playerStore: PlayerStore) {
    self.playerStore = playerStore
    super.init()
    self.name = NAME
    self.addChildNode(Models.attackShip.clone())
  }
  
  func animateDeath() {
    let fadeAction = SCNAction.fadeOut(duration: 1.5)
    runAction(fadeAction)
  }
  func animateRespawn() {
    let fadeAction = SCNAction.fadeIn(duration: 1.5)
    runAction(fadeAction)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

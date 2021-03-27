//
//  Player.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/24/21.
//

import SceneKit

class Player {
  var name = "mad bomber"
  var hitPoints = C_PLAYER.startingHealth
  let hitPointsMax = C_PLAYER.startingHealth
  var isCPU = false
 
  var attackShip: AttackShip?
  var offenseBoard: Board?
  var defenseBoard: Board?
  
  var isDead: Bool { hitPoints <= 0 }
}

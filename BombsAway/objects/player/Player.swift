//
//  Player.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/24/21.
//

import SceneKit

class Player {
  let gameSettings: GameSettings
  let playerId: Int
  let name: String

  var isCPU = false
  var hitPoints: Int
  var currentTurn: GameTurn?

  // calculateds
  var isDead: Bool { hitPoints <= 0 }
  var hitPointsMax: Int { gameSettings.hitPointsMax }
  var moveRadius: Int { gameSettings.moveRadius }
  var probeRadius: Int { gameSettings.probeRadius }
  var shootRadius: Int { gameSettings.shootRadius }
  
  init(playerId: Int, name: String, gameSettings: GameSettings) {
    self.gameSettings = gameSettings
    self.playerId = playerId
    self.name = name
    self.hitPoints = gameSettings.hitPointsMax
  }
 
  var attackShip: AttackShip?
  var offenseBoard: Board?
  var defenseBoard: Board?
  
}

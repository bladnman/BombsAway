//
//  PlayerStore.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/27/21.
//

import Foundation
class PlayerStore {
  let playerId:Int
  let boardStore: BoardStore
  let gameSettings: GameSettings
  var gridPoint = GridPoint.zero

  var attackers = [AttackerData]()
  
  let name: String

  var isCPU = false
  var hitPoints: Int
  
  // who you are attacking
  var targetPlayerId: Int = -1
  
  // refs
  var attackShip: AttackShip?
  var offenseBoard: Board?
  var defenseBoard: Board?
  
  // calculateds
  var isDead: Bool { hitPoints <= 0 }
  var hitPointsMax: Int { gameSettings.hitPointsMax }
  var moveRadius: Int { gameSettings.moveRadius }
  var probeRadius: Int { gameSettings.probeRadius }
  var shootRadius: Int { gameSettings.shootRadius }
  var actionsPerTurn: Int { gameSettings.actionCount }
  
  
  init(playerId: Int, playerName: String, gameSettings: GameSettings) {
    self.gameSettings = gameSettings
    self.playerId = playerId
    self.name = playerName
    self.hitPoints = gameSettings.hitPointsMax
    self.boardStore = BoardStore(playerId: playerId)
  }
}

//
//  PlayerStore.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/27/21.
//

import Foundation
class PlayerStore {
  var boardStore = BoardStore()
  var player: Player
  var attackers = [AttackerData]()
  
  init(player: Player) {
    self.player = player
  }
  init(playerId: Int, playerName: String, gameSettings: GameSettings) {
    self.player = Player(playerId: playerId,
                         name: playerName,
                         gameSettings: gameSettings)
  }
}

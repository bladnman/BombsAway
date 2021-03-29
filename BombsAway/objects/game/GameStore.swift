//
//  GameStore.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/27/21.
//

import Foundation
class GameStore {
  var playerStores = [PlayerStore]()
  var gameSettings = GameSettings()

  // calculateds
  var currentTurn: GameTurn? { playerStores.first(where: {$0.player.currentTurn != nil})?.player.currentTurn }
  
  func playerStoreForId(_ playerId: Int) -> PlayerStore? {
    return playerStores.first(where: {$0.player.playerId == playerId })
  }
  func startNextTurn() {
    let currentTurnPlayerIndex = playerStores.firstIndex(where: {$0.player.currentTurn != nil})
    
    // clear last turn
    if currentTurnPlayerIndex != nil {
      playerStores[currentTurnPlayerIndex!].player.currentTurn = nil
    }
    
    // move to next player
    let nextIdx = currentTurnPlayerIndex == nil || currentTurnPlayerIndex! == playerStores.count - 1 ? 0 : currentTurnPlayerIndex! + 1
    
    let gameTurn = GameTurn(playerId: playerStores[nextIdx].player.playerId)
    playerStores[nextIdx].player.currentTurn = gameTurn
  }
}

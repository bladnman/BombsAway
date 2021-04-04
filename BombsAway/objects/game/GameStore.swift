//
//  GameStore.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/27/21.
//

import Foundation
class GameStore {
  var gameSettings = GameSettings()

  
  // MARK: PLAYERS
  var playerStores = [PlayerStore]()
  func addPlayerStore(_ playerStore: PlayerStore) {
    playerStores.append(playerStore)
    playerIdTurnOrder.append(playerStore.playerId)
  }
  func playerStoreForId(_ playerId: Int) -> PlayerStore? {
    return playerStores.first(where: { $0.playerId == playerId })
  }
  var currentTurnPlayerStore: PlayerStore? {
    return playerStores.first(where: { $0.playerId == _currentTurn?.playerId })
  }
  func areAllShipsSunkForPlayerId(_ playerId: Int) -> Bool {
    
    if let boardStore = playerStoreForId(playerId)?.boardStore {
      
      // must have ships
      guard boardStore.ships.count > 0 else {
        return false
      }
      
      for ship in boardStore.ships {
        if !boardStore.isShipSunk(ship) {
          return false
        }
      }

      // no un-sunk ships
      return true
    }
    
    // no board store
    return false
  }
  var nextTurnPlayerStore: PlayerStore? {
    let nextPlayerId = getNextPlayerId()
    return playerStores.first(where: { $0.playerId == nextPlayerId })
  }
  
  // MARK: TURNS
  var _currentTurn: GameTurn?
  var lastTurn: GameTurn?
  var currentTurn: GameTurn {
    if _currentTurn == nil {
      startNextTurn()
    }
    return _currentTurn!
  }
  var playerIdTurnOrder = [Int]()
  func startNextTurn() {
    if let nextPlayer = nextTurnPlayerStore {
      _currentTurn = GameTurn(playerId: nextPlayer.playerId)
      _currentTurn?.totalActionCount = nextPlayer.actionsPerTurn
    }
  }
  func getNextPlayerId() -> Int {
    let currentTurnPlayerId = currentTurnPlayerStore?.playerId
    let finalTurnPlayerId = playerIdTurnOrder[playerIdTurnOrder.count - 1]
    let loopToFirstPlayer = (currentTurnPlayerId == nil || currentTurnPlayerId == finalTurnPlayerId)
    // move to next player
    var nextPlayerId = playerIdTurnOrder[0]
    
    // find next index if not first player
    if loopToFirstPlayer == false {
      let currentPlayerTurnIdx = playerIdTurnOrder.firstIndex(of: currentTurnPlayerId!)
      nextPlayerId = playerIdTurnOrder[1 + currentPlayerTurnIdx!]
    }
    return nextPlayerId
  }
  

  // MARK: BOARD
  var currentPlayerId: Int { currentTurn.playerId }
  var currentPlayerBoard: Board? {
    if let playerStore = currentTurnPlayerStore {
      return playerStore.boardStore.boardRef
    }
    
    return nil
  }
  var currentPlayerAttackingBoard: Board? {
    if let playerStore = currentTurnPlayerStore {
      let targetPlayerId = playerStore.targetPlayerId
      if let targetPlayerStore = playerStoreForId(targetPlayerId) {
        return targetPlayerStore.boardStore.boardRef
      }
    }
    
    return nil
  }
}

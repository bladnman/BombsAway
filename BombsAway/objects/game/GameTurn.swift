//
//  GameTurn.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/22/21.
//

import SceneKit
class GameTurn: CustomStringConvertible {
  var playerId: Int
  var totalActionCount: Int = 0
  var actions = [GameAction]()

  // calculateds
  var isOver: Bool { actions.count >= totalActionCount }
  
  init(playerId: Int) {
    self.playerId = playerId
  }
  func cancelRemainingActions() {
    if actions.count < totalActionCount {
      for _ in actions.count...totalActionCount {
        actions.append(GameAction.canceled)
      }
    }
  }
  func actionForIndex(_ index: Int) -> GameAction? {
    if actions.count >= index + 1 {
      return actions[index]
    }
    return nil
  }
}

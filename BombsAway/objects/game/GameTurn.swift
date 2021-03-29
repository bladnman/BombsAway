//
//  GameTurn.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/22/21.
//

import SceneKit

class GameTurn: CustomStringConvertible {
  var actions = [GameAction]()
  var isOver = false
  var board: Board?
  var playerId: Int
  
  var nextActionType = GameActionType.none { didSet { update() }}
  var nextActionGridPoint: GridPoint? { didSet { update() }}
  
  init(playerId: Int) {
    self.playerId = playerId
  }
  
  
  func update() {
    
    // set our board mode
    board?.mode = nextActionType
    
    // ACTION COMPLETE
    if nextActionType != .none && nextActionGridPoint != nil {
      let nextAction = GameAction(nextActionType, nextActionGridPoint)
      board?.performAction(nextAction)
      actions.append(nextAction)
      clearNextAction()
    }
  }
  func clearNextAction() {
    nextActionType = .none
    nextActionGridPoint = nil
  }
}

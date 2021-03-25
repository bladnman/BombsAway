//
//  GameAction.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/22/21.
//

import SceneKit

class GameAction: CustomStringConvertible {

  var type: GameActionType
  var gridPoint: GridPoint?

  init(_ type: GameActionType, _ gridPoint: GridPoint? = nil) {
    self.type = type
    self.gridPoint = gridPoint
  }
  static var zero: GameAction { return GameAction(.none) }
}

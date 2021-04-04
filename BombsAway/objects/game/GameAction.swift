//
//  GameAction.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/22/21.
//

import SceneKit

class GameAction: CustomStringConvertible {

  var type: GameActionType
  var actionOwnerId: Int
  var actionTargetId: Int
  var gridPoints = [GridPoint]()

  init(type: GameActionType,
       actionOwnerId: Int,
       actionTargetId: Int,
       gridPoints: [GridPoint]? = nil) {
    self.type = type
    self.actionOwnerId = actionOwnerId
    self.actionTargetId = actionTargetId
    if gridPoints != nil {
      self.gridPoints.append(contentsOf: gridPoints!)
    }
  }
  static var zero: GameAction { return GameAction(type: .none, actionOwnerId: -1, actionTargetId: -1) }
  static var canceled: GameAction { return GameAction(type: .canceled, actionOwnerId: -1, actionTargetId: -1) }
}

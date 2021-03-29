//
//  GameSettings.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/27/21.
//

import Foundation
class GameSettings {
  var actionCount = C_PLAYER.startingActionsPerTurn
  var moveRadius = C_MOVE.Player.initialMoveRadius
  var probeRadius = C_MOVE.Player.initialProbeRadius
  var shootRadius = C_MOVE.Player.initialShootRadius
  var boardSize = BoardSize(columns: C_BOARD.Size.columns, rows: C_BOARD.Size.rows)
  var shipSizeArray = C_PLAYER.shipSizeArray
  var hitPointsMax = C_PLAYER.startingHealth
}

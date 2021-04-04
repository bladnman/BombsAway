//
//  GS+camera.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/12/21.
//

import QuartzCore
import SceneKit
import SpriteKit
import UIKit

// MARK: OVERLAY DELEGATE

extension GameViewController: MainHUDProtocol {

  func mainHUDMovePressed() {
    nextActionType = .move
    gameStore.currentPlayerAttackingBoard?.mode = .move
  }
  func mainHUDProbePressed() {
    nextActionType = .probe
    gameStore.currentPlayerAttackingBoard?.mode = .probe
  }
  func mainHUDShootPressed() {
    nextActionType = .shoot
    gameStore.currentPlayerAttackingBoard?.mode = .shoot
  }
  func mainHUDMoveToNextPlayerPressed() {
    lifeCy_startPassAndPlayHandoff()
  }
  func mainHUDHandoffCompletePressed() {
    lifeCy_endPassAndPlayHandoff()
  }
  func mainHUDHandledTouchStart() {
    // noop
  }
  func mainHUDHandledTouchEnd() {
    // noop
  }
}

// MARK: TOUCH HANDLERS

extension GameViewController {
  
  // move me to another place
  func doAction(gameAction: GameAction, boardOwnerId: Int) {
    // look up the board to do action on
    if let playerStore = gameStore.playerStoreForId(boardOwnerId) {
      
      playerStore.boardStore.boardRef?.performAction(gameAction)
      gameStore.currentTurn.actions.append(gameAction)
    }

    // clear to start over
    nextActionType = .none
    nextActionGridPoint = nil
  }
  
  func cellSelected(cell: BoardCell) {
    // make sure this cell has an action mode
    if cell.mode != .none {

      // MARK: !!  DO ACTION  !!
      nextActionGridPoint = cell.gridPoint
      if nextActionType != .none || nextActionGridPoint != nil {
        let boardOwnerId = cell.boardStore.playerId
        
        let gameAction = GameAction(type: nextActionType,
                                    actionOwnerId: gameStore.currentPlayerId,
                                    actionTargetId: boardOwnerId,
                                    gridPoints: [cell.gridPoint])
        
        doAction(gameAction: gameAction, boardOwnerId: boardOwnerId)
        
        cell.board.mode = .none
      }
    }
  }

  @objc
  func handleTap(_ gestureRecognize: UIGestureRecognizer) {
    // retrieve the SCNView
    let scnView = view as! SCNView

    // check what nodes are tapped
    let p = gestureRecognize.location(in: scnView)
    let options: [SCNHitTestOption: Any] = [SCNHitTestOption.backFaceCulling: true,
                                            SCNHitTestOption.searchMode: 1,
                                            SCNHitTestOption.ignoreChildNodes: false,
                                            SCNHitTestOption.ignoreHiddenNodes: false]
    let hitResults = scnView.hitTest(p, options: options)
    // check that we clicked on at least one object
    if hitResults.count > 0 {
      // retrieved the first clicked object
      let result = hitResults[0]

      let resultNode = result.node

      if let boardCellFloor = hitResults.first(where: { $0.node.name == C_OBJ_NAME.cellFloor })?.node {
        if let boardCell = ScnUtils.getAncestorWithName(boardCellFloor, name: C_OBJ_NAME.boardCell) as? BoardCell {
          cellSelected(cell: boardCell)
        }
      }

      // MARK: temporary BOARD RESET

      if resultNode.name == C_OBJ_NAME.worldFloor {
//        removeAllShips()
      }
    }
  }
}

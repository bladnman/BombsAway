//
//  GameViewController.swift
//  BombsAway
//
//  Created by Maher, Matt on 2/28/21.
//

import QuartzCore
import SceneKit
import SpriteKit
import UIKit

class GameViewController: UIViewController {
  var scene: SCNScene!
  var sceneView: SCNView!

  var gameStore = GameStore()
  var nextAction: GameAction?

  // holders for next action, until action is complete
  var nextActionType = GameActionType.none
  var nextActionGridPoint: GridPoint?
  
  var farBoard: Board!
  var nearBoard: Board!
  var gameHUD: MainHUD?
  
  var playerNode: SCNNode!
  
  var lastWidthRatio: Float = 0
  var lastHeightRatio: Float = 0
  
  // CAMERA
  var cameraNode: SCNNode!
  var cameraOmni: SCNNode!
  var cameraNear: SCNNode!
  var cameraFar: SCNNode!
  var isPOVNear: Bool { cameraNode.position == cameraNear.position }
  var isPOVFar: Bool { cameraNode.position == cameraFar.position }
  var isPOVOmni: Bool { cameraNode.position == cameraOmni.position }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initializeGame()
  }

  func initializeGame() {
    createNewScene()
  }

  // OVERRIDES
  override var shouldAutorotate: Bool {
    return true
  }
  override var prefersStatusBarHidden: Bool {
    return true
  }
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    if UIDevice.current.userInterfaceIdiom == .phone {
      return .allButUpsideDown
    } else {
      return .all
    }
  }
}

// MARK: GAME LIFECYCLE
extension GameViewController {

  func lifeCy_beginTurn() {

    gameStore.startNextTurn()
    
    if let currentTurnPlayerStore = gameStore.currentTurnPlayerStore {
      gameHUD?.playerStore = currentTurnPlayerStore
    }
    
    // we need boards! (pass and play they are destroyed)
    if farBoard == nil {
      createAllBoards()
    }
    
    // we show last player's turn first
    lifeCy_defend()
    
    // then we move on with attack
    lifeCy_attack()
    
  }
  func lifeCy_defend() {
    povNear()
  }
  func lifeCy_attack() {
//    povFar()
    gameHUD?.state = .turn
    if let currentTurnPlayerStore = gameStore.currentTurnPlayerStore {
      
      // MARK: RESPAWN
      if currentTurnPlayerStore.isDead {
        currentTurnPlayerStore.hitPoints = currentTurnPlayerStore.hitPointsMax
        gameStore.currentPlayerAttackingBoard?.respawn()
        
        if C_PLAYER.respawnLosesTurn {
          lifeCy_endTurn()
        }
        
        gameHUD?.update()
      }
    }
  }
  func lifeCy_endTurn() {
//    povOmni()
    gameStore.currentTurn.cancelRemainingActions()
    gameHUD?.state = .endOfTurn
  }
  func lifeCy_startPassAndPlayHandoff() {
    gameHUD?.state = .handoff
    
    // tear down boards
    removeAllBoards()
  }
  func lifeCy_endPassAndPlayHandoff() {
    lifeCy_beginTurn()
  }


  func lifeCy_victory() {
    gameHUD?.state = .victory
  }
}

// MARK: BOARD DELEGATE
extension GameViewController: BoardProtocol {
  func boardActionComplete(gameAction: GameAction, board: Board) {
    if let targetPlayer = gameStore.playerStoreForId(gameAction.actionTargetId) {
      if let attackingPlayer = gameStore.playerStoreForId(gameAction.actionOwnerId) {
        
        // MARK: VICTORY
        if gameStore.areAllShipsSunkForPlayerId(targetPlayer.playerId) {
          lifeCy_victory()
        }
    
        // MARK: DEAD
        else if attackingPlayer.isDead {
          board.killAttacker()
          
          // MARK: todo want to wait until attacker is dead...

          // maybe a completion callback?
          lifeCy_endTurn()
        }
        
        // MARK: CURRENT TURN OVER - NO MORE ACTIONS
        else if gameStore.currentTurn.isOver {
          lifeCy_endTurn()
        }
      }
    }
    
    gameHUD?.update()
  }
}

// MARK: SCENE UPDATE DELEGATE
extension GameViewController: SCNSceneRendererDelegate {
  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    // noop
  }
}

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
  var offenseBoard: Board!
  var defenseBoard: Board!
  var player: SCNNode!
  var gameHUD: MainHUD?
  var nextAction: GameAction?
  var currentTurn = GameTurn()
  var player1 = Player()
  var player2 = Player()
  
  // CAMERA
  var camera: SCNNode!
  var lastWidthRatio: Float = 0
  var lastHeightRatio: Float = 0

  override func viewDidLoad() {
    super.viewDidLoad()
    initializeGame()
  }
  func initializeGame() {
    createNewScene()
    startNewTurn()
  }
  func startNewTurn() {
    currentTurn = GameTurn()
    currentTurn.board = offenseBoard
  }
  
  
  
  
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


// MARK: OVERLAY DELEGATE
extension GameViewController: MainHUDProtocol {
  func mainHUDMovePressed() {
    currentTurn.nextActionType = .move
  }
  func mainHUDProbePressed() {
    currentTurn.nextActionType = .probe
  }
  func mainHUDShootPressed() {
    currentTurn.nextActionType = .shoot
  }
  func mainHUDHandledTouchStart() {
    // noop
  }
  func mainHUDHandledTouchEnd() {
    // noop
  }
}


// MARK: BOARD DELEGATE
extension GameViewController: BoardProtocol {
  func boardSubstantialChage(board: Board) {
    // MARK: DEAD
    if board.attacker.isDead {
      currentTurn.isOver = true
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

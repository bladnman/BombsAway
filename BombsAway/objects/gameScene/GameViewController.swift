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
  var defendBoard: Board!
  var player: SCNNode!
  var gameHUD: MainHUD?
  var nextAction: GameAction?
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
    nextAction = GameAction(.move)
    offenseBoard.mode = .move
  }
  func mainHUDProbePressed() {
    nextAction = GameAction(.probe)
    offenseBoard.mode = .probe
  }
  func mainHUDShootPressed() {
    nextAction = GameAction(.shoot)
    offenseBoard.mode = .shoot
  }
  func mainHUDHandledTouchStart() {
    // noop
  }
  func mainHUDHandledTouchEnd() {
    // noop
  }
}

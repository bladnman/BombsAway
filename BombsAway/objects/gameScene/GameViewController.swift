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
  var attackBoard: Board!
  var defendBoard: Board!
  var player: SCNNode!
  
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
  
  @objc
  func handleTap(_ gestureRecognize: UIGestureRecognizer) {
    // retrieve the SCNView
    let scnView = view as! SCNView
    
    // check what nodes are tapped
    let p = gestureRecognize.location(in: scnView)
    
    let options : [SCNHitTestOption: Any] = [SCNHitTestOption.backFaceCulling: true,
                                           SCNHitTestOption.searchMode: 1,
                                           SCNHitTestOption.ignoreChildNodes : false,
                                           SCNHitTestOption.ignoreHiddenNodes : false]
    let hitResults = scnView.hitTest(p, options: options)
    
    // check that we clicked on at least one object
    if hitResults.count > 0 {
      // retrieved the first clicked object
      let result = hitResults[0]
      
      let resultNode = result.node
      if let boardCellFloor = hitResults.first(where: { $0.node.name == C_OBJ_NAME.cellFloor })?.node {
        if let boardCell = getAncestorWithName(boardCellFloor, name: C_OBJ_NAME.boardCell) as? BoardCell {
          if boardCell.mode == .move {
            if let board = boardCell.parent?.parent as? Board {
              board.stepPlayerShipTo(boardCell.gridPoint)
            }
          }
        }
      }
      if let ship = hitResults.first(where: { $0.node.name == C_OBJ_NAME.ship })?.node {
        print("[M@] [\(ship)]")
      }
      
      if resultNode.name == C_OBJ_NAME.worldFloor {
        removeAllShips()
      } else {
        // get its material
        let material = resultNode.geometry!.firstMaterial!
              
        // highlight it
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.1
        material.emission.contents = UIColor.white
        material.emission.intensity = 0.2
              
        // on completion - unhighlight
        SCNTransaction.completionBlock = {
          SCNTransaction.begin()
          SCNTransaction.animationDuration = 1.5
          material.emission.contents = UIColor.black
          SCNTransaction.commit()
        }
              
        SCNTransaction.commit()
      }
    }
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

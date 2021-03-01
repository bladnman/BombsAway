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
  var gridNode: GridNode!
  
  override func viewDidLoad() {
    super.viewDidLoad()
        
    createNewScene()
        
  }
  func initializeGame() {
    createNewScene()
//    setupPlayer()
//    setupCollisionNode()
//    setupActions()
  }
    
  @objc
  func handleTap(_ gestureRecognize: UIGestureRecognizer) {
    // retrieve the SCNView
    let scnView = self.view as! SCNView
        
    // check what nodes are tapped
    let p = gestureRecognize.location(in: scnView)
    let hitResults = scnView.hitTest(p, options: [:])
    // check that we clicked on at least one object
    if hitResults.count > 0 {
      // retrieved the first clicked object
      let result = hitResults[0]
            
      // get its material
      let material = result.node.geometry!.firstMaterial!
            
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

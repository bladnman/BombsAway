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

extension GameViewController {
  
  
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
        if let boardCell = ScnUtils.getAncestorWithName(boardCellFloor, name: C_OBJ_NAME.boardCell) as? BoardCell {
          if C_CELL.SELECTABLE_MODES.contains(boardCell.mode)  {
            if let board = boardCell.parent?.parent as? Board {
              
              if nextAction != nil {
                nextAction!.gridPoint = boardCell.gridPoint
                board.performAction(nextAction!)
              }
              // clear+freeze board
              board.mode = .none
            }
          }
        }
      }
//      if let ship = hitResults.first(where: { $0.node.name == C_OBJ_NAME.ship })?.node {
//        print("[M@] handleTap [\(ship)]")
//      }
      
      if resultNode.name == C_OBJ_NAME.worldFloor {
        removeAllShips()
      }
      
      // original highlight feature
//      else {
//        // get its material
//        let material = resultNode.geometry!.firstMaterial!
//
//        // highlight it
//        SCNTransaction.begin()
//        SCNTransaction.animationDuration = 0.1
//        material.emission.contents = UIColor.white
//        material.emission.intensity = 0.2
//
//        // on completion - unhighlight
//        SCNTransaction.completionBlock = {
//          SCNTransaction.begin()
//          SCNTransaction.animationDuration = 1.5
//          material.emission.contents = UIColor.black
//          SCNTransaction.commit()
//        }
//
//        SCNTransaction.commit()
//      }
    }
  }
  
  
//  func handlePanGesture(sender: UIPanGestureRecognizer) {
//    let translation = sender.translation(in: sender.view!)
//    let widthRatio = Float(translation.x) / Float(sender.view!.frame.size.width) + lastWidthRatio
//    let heightRatio = Float(translation.y) / Float(sender.view!.frame.size.height) + lastHeightRatio
//
//    self.cameraOrbit.eulerAngles.y = Float(-2 * M_PI) * widthRatio
//    self.cameraOrbit.eulerAngles.x = Float(-M_PI) * heightRatio
//
//    if sender.state == .ended {
//      lastWidthRatio = widthRatio % 1
//      lastHeightRatio = heightRatio % 1
//    }
//  }
}

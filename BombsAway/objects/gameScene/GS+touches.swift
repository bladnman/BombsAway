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
          // make sure this cell has an action mode
          if boardCell.mode != .none {
            // make sure this cell belongs to the nextTurn
            if boardCell.board == currentTurn.board {
              // MARK: GP for next action
              currentTurn.nextActionGridPoint = boardCell.gridPoint
            }
          }
        }
      }

      // MARK: temporary BOARD RESET
      if resultNode.name == C_OBJ_NAME.worldFloor {
        removeAllShips()
      }
      
    }
  }
}

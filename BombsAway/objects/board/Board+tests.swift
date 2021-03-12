//
//  Board+tests.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/7/21.
//
import SceneKit
import UIKit
extension Board {
  func clearHitTestObjects() {
    boardGeom.enumerateChildNodes { node, _ in
      if node.name == "HIT-TEST-OBJECT" {
        node.removeFromParentNode()
      }
    }
  }
  func createPlacementNodes() {
    placementStartNode = getPlacementNode(UIColor.fromHex("#27ae60"))
    placementEndNode = getPlacementNode(UIColor.fromHex("#34495e"))
    boardGeom.addChildNode(placementStartNode)
    boardGeom.addChildNode(placementEndNode)
  }
  func showPlacementIndicatorsAt(_ startGP: GridPoint, _ endGP: GridPoint) {
    let finalStartPosition = SCNVector3(startGP.column, 1, startGP.row)
    let finalEndPosition = SCNVector3(endGP.column, 1, endGP.row)
    
    let moveStartAction = SCNAction.move(to: finalStartPosition, duration: 0.2)
    let moveEndAction = SCNAction.move(to: finalEndPosition, duration: 0.3)
    moveStartAction.timingMode = .easeOut
    moveEndAction.timingMode = .easeIn
    placementStartNode.runAction(moveStartAction)
    placementEndNode.runAction(moveEndAction)
  }
  func getPlacementNode(_ color: UIColor = UIColor.fromHex("#34495e")) -> SCNNode {
    let boxGeometry = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0.2)
    boxGeometry.firstMaterial?.diffuse.contents = color
    let node = SCNNode(geometry: boxGeometry)
    node.name = "PLACEMENT-NODE"
    return node
  }
  
}

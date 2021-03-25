//
//  SCNNode+ext.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/10/21.
//

import SceneKit

extension SCNNode {
  func showPivotIndicator() {
    removePivotIndicator()
    ScnUtils.createPivotIndicator(self)
  }

  func removePivotIndicator() {
    if let _pivotIndicator = childNodes.filter({ $0.name == C_OBJ_NAME.pivot }).first {
      _pivotIndicator.removeAllActions()
      _pivotIndicator.removeFromParentNode()
    }
  }
}

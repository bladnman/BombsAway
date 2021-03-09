//
//  PlayerNode.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/8/21.
//

import SceneKit

class PlayerNode: SCNNode {
  var stepSize: Int = 2
  var gridPoint: GridPoint {
    get {
      return GridPoint(Int(position.x), Int(position.z))
    }
  }
}

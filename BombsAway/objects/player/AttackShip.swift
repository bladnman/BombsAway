//
//  PlayerNode.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/8/21.
//

import SceneKit

class AttackShip: SCNNode {
  let NAME = C_OBJ_NAME.player
  var stepSize: Int = C_MOVE.Player.initialStepsPerMove
  var gridPoint: GridPoint {
    get {
      return GridPoint(Int(position.x), Int(position.z))
    }
  }
  
  override init() {
    super.init()
    self.name = NAME
    
//    let boxGeometry = SCNBox(width: 0.7, height: 0.1, length: 0.7, chamferRadius: 0.04)
//    boxGeometry.firstMaterial?.diffuse.contents = UIColor.white
//    boxGeometry.firstMaterial?.transparency = 0.8
//    boxGeometry.firstMaterial?.emission.intensity = 0.8
//    self.geometry = boxGeometry
    
    self.addChildNode(Models.attackShip.clone())
  }
    
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

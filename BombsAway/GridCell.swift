//
//  GridCell.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/1/21.
//

import SceneKit

class GridCell: SCNNode {
  let column: Int
  let row: Int
  
  init(_ column: Int, _ row: Int) {
    self.column = column
    self.row = row
    super.init()
    
    self.geometry = SCNPlane(width: 1, height: 1)
    self.geometry?.firstMaterial?.diffuse.contents = UIColor.darkGray
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

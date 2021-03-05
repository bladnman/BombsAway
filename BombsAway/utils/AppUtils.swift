//
//  AppUtils.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/4/21.
//

import SceneKit

func getRotationArray() -> [Float] {
  let arr = [Float(0.0), Float(90.0), Float(180.0), Float(270.0)]
  return arr.shuffled()
}

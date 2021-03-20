//
//  AppUtils.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/4/21.
//

import SceneKit
class ThreatDirections {
  var n = false
  var e = false
  var w = false
  var s = false
  var ne = false
  var se = false
  var sw = false
  var nw = false
  var center = false
  func setForDirection(_ direction: Direction, _ hasThreats: Bool) {
    switch direction {
    case .n: n = hasThreats
    case .e: e = hasThreats
    case .s: s = hasThreats
    case .w: w = hasThreats
    case .ne: ne = hasThreats
    case .se: se = hasThreats
    case .sw: sw = hasThreats
    case .nw: nw = hasThreats
    }
  }
}

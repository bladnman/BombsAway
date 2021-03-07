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

func makeShip(_ width: Int, _ color: UIColor = UIColor.randomColor()) -> SCNNode {
  let boxGeometry = SCNBox(width: CGFloat(width), height: 1.0, length: 1.0, chamferRadius: 0.04)
  boxGeometry.firstMaterial?.diffuse.contents = color
  boxGeometry.firstMaterial?.transparency = 0.7
  let node = SCNNode(geometry: boxGeometry)
  node.name = "SHIP"
  
  // PIVOT POINT:  left, bottom, 1/2 length
  node.pivot = SCNMatrix4MakeTranslation(-0.5 * Float(width), -0.5, 0.0);
  return node
}
//func makeShip(_ width: Int = 1, _ length: Int = 1, _ color: UIColor = UIColor.randomColor()) -> SCNNode {
//  let boxGeometry = SCNBox(width: CGFloat(width), height: 1.0, length: CGFloat(length), chamferRadius: 0.04)
//  boxGeometry.firstMaterial?.diffuse.contents = color
//  boxGeometry.firstMaterial?.transparency = 0.7
//  let node = SCNNode(geometry: boxGeometry)
//  node.name = "SHIP"
//
////    node.pivot = SCNMatrix4MakeTranslation(0.0, 0.0, 0.0) // move up to float
////    node.localRotate(by: SCNQuaternion(x: 0, y: 0.7071, z: 0, w: 0.7071))
////    node.rotation = SCNVector4Make(0, 1, 0, Float(Double.pi/2));
//
//
//  node.pivot = SCNMatrix4MakeTranslation(0.0, 0.0, -0.5 * Float(length));
//  return node
//}

func dumpHitResults(_ hitResults: [SCNHitTestResult], _ name: String? = nil) {
  if !hitResults.isEmpty {
    if name != nil {
      print("[M@] HIT RESULTS FOR [\(name ?? "")]")
    }
    print("[M@]     - hits.count  [\(hitResults.count)]")
    for hit in hitResults {
      print("[M@]     - HIT: [\(hit.node)]")
    }
  } else {
    if name != nil {
      print("[M@] no hit results for [\(name ?? "")]")
    } else {
      print("[M@] not hit results")
    }
  }
}

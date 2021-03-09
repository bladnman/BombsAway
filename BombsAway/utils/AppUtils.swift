//
//  AppUtils.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/4/21.
//

import SceneKit
// https://flatuicolors.com/palette/defo
let shipColors:[String] = [
  "#1abc9c",
  "#2ecc71",
  "#3498db",
  "#9b59b6",
  "#f1c40f",
  "#e67e22",
  "#e74c3c",
]
func getRotationArray() -> [Float] {
  let arr = [Float(0.0), Float(90.0), Float(180.0), Float(270.0)]
  return arr.shuffled()
}

func makeShip(_ width: Int, _ color: UIColor = randomShipColor()) -> SCNNode {
  let boxGeometry = SCNBox(width: CGFloat(width), height: 1.0, length: 1.0, chamferRadius: 0.04)
  boxGeometry.firstMaterial?.diffuse.contents = color
//  boxGeometry.firstMaterial?.transparency = 0.7
  let node = SCNNode(geometry: boxGeometry)
  node.name = C_OBJ_NAME.ship

  // PIVOT POINT:  left, bottom, 1/2 length
  node.pivot = SCNMatrix4MakeTranslation(-0.5 * Float(width), -0.5, 0.0)
  return node
}
func randomShipColor() -> UIColor {
  return UIColor.fromHex(shipColors.randomElement()!)
}
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

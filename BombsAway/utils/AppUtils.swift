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

struct Models {
  private static let blueCoinScene = SCNScene(named: "art.scnassets/coin-test.scn")!
  static let blueCoin = blueCoinScene.rootNode.childNode(withName: "cointest", recursively: true)!
  
  private static let redCoinScene = SCNScene(named: "art.scnassets/coin-test-red.scn")!
  static let redCoin = redCoinScene.rootNode.childNode(withName: "cointest", recursively: true)!
  
  private static let boardCellScene = SCNScene(named: "boardCell.scnassets/Base.scn")!
  static let boardCell = boardCellScene.rootNode.childNode(withName: "node", recursively: true)!

  private static let boardCellFloorScene = SCNScene(named: "boardCell.scnassets/Floor.scn")!
  static let cellFloor = boardCellFloorScene.rootNode.childNode(withName: "cellFloor", recursively: true)!
  
}

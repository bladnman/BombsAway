//
//  AppUtils.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/4/21.
//

import SceneKit
import SpriteKit

enum TouchPhase {
  case start, end
}
enum GameActionType {
  case none, shoot, probe, move, canceled
}


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
func gridPointsFor(boardRange: BoardRange) -> [GridPoint] {
  var gridPoints = [GridPoint]()
  for c in boardRange.columnRange {
    for r in boardRange.rowRange {
      gridPoints.append(GridPoint(c, r))
    }
  }
  return gridPoints
}


struct Models {
  static let _blueCoin: SCNNode = loadNodeFromSCNScene(sceneName: "art.scnassets/coin-test.scn", nodeName: "cointest")!
  static let _redCoin: SCNNode = loadNodeFromSCNScene(sceneName: "boardCell.scnassets/coin-test-red.scn", nodeName: "cointest")!
  static let boardCell: SCNNode = loadNodeFromSCNScene(sceneName: "boardCell.scnassets/Base.scn", nodeName: "node")!
  static let cellFloor: SCNNode = loadNodeFromSCNScene(sceneName: "boardCell.scnassets/Floor.scn", nodeName: C_OBJ_NAME.cellFloor)!
  static let _selectableIndicator: SCNNode = loadNodeFromSCNScene(sceneName: "boardCell.scnassets/SelectableIndicator.scn", nodeName: "node")!
  static let cellProbe: SCNNode = loadNodeFromSCNScene(sceneName: "boardCell.scnassets/Probe.scn", nodeName: "node")!
  static let attackShip: SCNNode = loadNodeFromSCNScene(sceneName: "boardCell.scnassets/AttackShip.scn", nodeName: "node")!
  static let _probabilityIndicator: SCNNode = loadNodeFromSCNScene(sceneName: "boardCell.scnassets/ProbabilityIndicator.scn", nodeName: "base")!
  static let _missIndicator: SCNNode = loadNodeFromSCNScene(sceneName: "boardCell.scnassets/MissIndicator.scn", nodeName: "base")!
  
  static var probabilityIndicator: ProbabilityIndicator { ProbabilityIndicator(ScnUtils.deepCopyNode(_probabilityIndicator)) }
  static var selectableIndicator: SCNNode { ScnUtils.deepCopyNode(_selectableIndicator) }
  static var missIndicator: SCNNode {
    let node = ScnUtils.deepCopyNode(_missIndicator)
    node.name = C_OBJ_NAME.missIndicator
    return node
  }
  static var redCoin: SCNNode {
    let node = ScnUtils.deepCopyNode(_redCoin)
    node.name = C_OBJ_NAME.sunkCoin
    return node
  }
  static var blueCoin: SCNNode {
    let node = ScnUtils.deepCopyNode(_blueCoin)
    node.name = C_OBJ_NAME.hitCoin
    return node
  }
  
}
func loadNodeFromSCNScene(sceneName: String, nodeName: String) -> SCNNode? {
  if let scene = SCNScene(named: sceneName) {
    if let node = scene.rootNode.childNode(withName: nodeName, recursively: true) {
      return node
    } else {
      print("[M@] ERROR: NODE NOT FOUND IN SCENE: sceneName:[\(sceneName)] looking for nodeName:[\(nodeName)]")
    }
  } else {
    print("[M@] ERROR: SCENE NOT FOUND: [\(sceneName)]")
  }
  
  return nil
}
func loadNodeFromSKScene(sceneName: String, nodeName: String) -> SKNode? {
  if let scene = SKScene(fileNamed: sceneName) {
    if let node = scene.childNode(withName: nodeName) {
      return node
    } else {
      print("[M@] ERROR: NODE NOT FOUND IN SCENE: sceneName:[\(sceneName)] looking for nodeName:[\(nodeName)]")
    }
  } else {
    print("[M@] ERROR: SCENE NOT FOUND: [\(sceneName)]")
  }
  
  return nil
}
func isUp(_ direction: Direction) -> Bool {
  switch direction {
  case .nw,.n,.ne:
    return true
  default:
    return false
  }
}
func isDown(_ direction: Direction) -> Bool {
  switch direction {
  case .sw,.s,.se:
    return true
  default:
    return false
  }
}
func isRight(_ direction: Direction) -> Bool {
  switch direction {
  case .ne,.e,.se:
    return true
  default:
    return false
  }
}
func isLeft(_ direction: Direction) -> Bool {
  switch direction {
  case .nw,.w,.sw:
    return true
  default:
    return false
  }
}



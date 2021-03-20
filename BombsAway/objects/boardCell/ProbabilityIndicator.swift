//
//  ProbabilityIndicator.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/20/21.
//


import SceneKit

private enum NodeState {
  case active, inactive, off
}

class ProbabilityIndicator: SCNNode {
  
  private let baseNode: SCNNode!
  private let nNode: SCNNode!
  private let eNode: SCNNode!
  private let sNode: SCNNode!
  private let wNode: SCNNode!
  private let neNode: SCNNode!
  private let seNode: SCNNode!
  private let swNode: SCNNode!
  private let nwNode: SCNNode!
  private let centerNode: SCNNode!
  
  var threats = ThreatDirections() { didSet { update() }}
  
  var n = false { didSet { update() }}
  var e = false { didSet { update() }}
  var w = false { didSet { update() }}
  var s = false { didSet { update() }}
  var ne = false { didSet { update() }}
  var se = false { didSet { update() }}
  var sw = false { didSet { update() }}
  var nw = false { didSet { update() }}
  var center = false { didSet { update() }}
  
  init(_ baseNode:SCNNode) {
    self.baseNode = baseNode

    self.nNode = getChildWithName(baseNode.childNodes, name: "n")!
    self.eNode = getChildWithName(baseNode.childNodes, name: "e")!
    self.sNode = getChildWithName(baseNode.childNodes, name: "s")!
    self.wNode = getChildWithName(baseNode.childNodes, name: "w")!
    self.neNode = getChildWithName(baseNode.childNodes, name: "ne")!
    self.seNode = getChildWithName(baseNode.childNodes, name: "se")!
    self.swNode = getChildWithName(baseNode.childNodes, name: "sw")!
    self.nwNode = getChildWithName(baseNode.childNodes, name: "nw")!
    self.centerNode = getChildWithName(baseNode.childNodes, name: "center")!
    
    
    super.init()
    self.addChildNode(baseNode)
    self.update()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  func update() {
    updateNode(nNode, state: threats.n ? .active : .inactive)
    updateNode(eNode, state: threats.e ? .active : .inactive)
    updateNode(sNode, state: threats.s ? .active : .inactive)
    updateNode(wNode, state: threats.w ? .active : .inactive)
    updateNode(neNode, state: threats.ne ? .active : .inactive)
    updateNode(seNode, state: threats.se ? .active : .inactive)
    updateNode(swNode, state: threats.sw ? .active : .inactive)
    updateNode(nwNode, state: threats.nw ? .active : .inactive)
    
    updateNode(centerNode, state: threats.center ? .active : .off)
  }
  private func updateNode(_ node: SCNNode, state: NodeState) {
    switch state {
    case .active:
      node.opacity = 1.0
      node.geometry?.firstMaterial?.diffuse.contents = UIColor.fromHex("#FF3F00")
      node.geometry?.firstMaterial?.transparency = 1.0
    case .inactive:
      node.opacity = 1.0
      node.geometry?.firstMaterial?.diffuse.contents = UIColor.white
      node.geometry?.firstMaterial?.transparency = 0.05
    case .off:
      node.opacity = 0.0
    }
    
    for child in node.childNodes {
      updateNode(child, state: state)
    }
  }
}

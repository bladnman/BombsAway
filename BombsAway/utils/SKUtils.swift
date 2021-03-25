//
//  SpriteKitUtils.swift
//
//  Created by Maher, Matt on 2/10/21.
//
import SpriteKit

class SKUtils {
  static func showBoundingBox(_ node: SKNode, _ color: UIColor = .green) {
    let toolNode = SKShapeNode(rectOf: node.calculateAccumulatedFrame().size)
    toolNode.lineWidth = 5.0
    toolNode.strokeColor = color
    toolNode.fillColor = .clear
    toolNode.path = toolNode.path?.copy(dashingWithPhase: 0, lengths: [10,10])
    toolNode.zPosition = 1000
    node.addChild(toolNode)
  }
  static func showFrameBox(_ node: SKNode, _ color: UIColor = .yellow) {
    let toolNode = SKShapeNode(rectOf: node.frame.size)
    toolNode.lineWidth = 5.0
    toolNode.strokeColor = color
    toolNode.fillColor = .clear
    toolNode.path = toolNode.path?.copy(dashingWithPhase: 0, lengths: [10,10])
    toolNode.zPosition = 1000
    node.addChild(toolNode)
  }
  static func showOrigin(_ node: SKNode, _ color: UIColor = .orange, _ radius: CGFloat = 40.0) {
    let toolNode = SKShapeNode(circleOfRadius: radius)
    toolNode.lineWidth = 10
    toolNode.strokeColor = color
    toolNode.fillColor = .clear
    toolNode.path = toolNode.path?.copy(dashingWithPhase: 0, lengths: [10,10])
    toolNode.zPosition = 1000
    node.addChild(toolNode)
  }
}

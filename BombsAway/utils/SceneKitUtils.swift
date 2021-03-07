//
//  SceneKitUtils.swift
//
//  Created by Maher, Matt on 2/10/21.
//
import SceneKit

func measure(_ node: SCNNode) -> SCNVector3 {
  let (min, max) = node.boundingBox
  let w = Float(max.x - min.x)
  let h = Float(max.y - min.y)
  let l = Float(max.z - min.z)
  
  return SCNVector3(x: w, y: h, z: l)
}
func measureToNodeSpace(_ node: SCNNode, to: SCNNode) -> SCNVector3 {
  let (minL, maxL) = node.boundingBox
  let min = node.convertPosition(minL, to: to)
  let max = node.convertPosition(maxL, to: to)
  let w = Float(max.x - min.x)
  let h = Float(max.y - min.y)
  let l = Float(max.z - min.z)
  
  return SCNVector3(x: w, y: h, z: l)
}
func ceil(_ vector: SCNVector3) -> SCNVector3 {
  return SCNVector3(ceilf(vector.x), ceilf(vector.y), ceilf(vector.z))
}
func rounded(_ vector: SCNVector3) -> SCNVector3 {
  return SCNVector3(vector.x.rounded(), vector.y.rounded(), vector.z.rounded())
}
func makeText(text: String, depthOfText: CGFloat, color: UIColor, transparency: CGFloat) -> SCNNode {
  // 1. Create An SCNNode With An SCNText Geometry
  let textNode = SCNNode()
  let textGeometry = SCNText(string: text, extrusionDepth: depthOfText)

  // 2. Set The Colour Of Our Text, Our Font & It's Size
  textGeometry.firstMaterial?.diffuse.contents = color
  textGeometry.firstMaterial?.isDoubleSided = true
  textGeometry.font = UIFont(name: "Skia-Regular_Black", size: 100)
  textGeometry.firstMaterial?.transparency = transparency

  // 3. Set It's Flatness To 0 So It Looks Smooth
  textGeometry.flatness = 0

  // 4. Set The SCNNode's Geometry
  textNode.geometry = textGeometry

  // center the pivot point
  let min = textNode.boundingBox.min
  let max = textNode.boundingBox.max
  let w = CGFloat(max.x - min.x)
  let h = CGFloat(max.y - min.y)
  let l = CGFloat(max.z - min.z)
  textNode.pivot = SCNMatrix4MakeTranslation(Float(w / 2), Float(h / 2), Float(l / 2))

  let scale = 0.02
  textNode.scale = SCNVector3(scale, scale, scale)

  return textNode
}
func createOriginIndicator(_ node: SCNNode, color: UIColor = UIColor.green) {
  let originNode = SCNNode(geometry: SCNBox(width: 0.1, height: 5.0, length: 0.1, chamferRadius: 0.3))
  originNode.geometry?.firstMaterial?.diffuse.contents = color
  originNode.name = "ORIGIN"
  originNode.position = SCNVector3(0, 0, 0)
  node.addChildNode(originNode)
}
func createPivotIndicator(_ node: SCNNode, color: UIColor = UIColor.green) {
  let originNode = SCNNode(geometry: SCNCone(topRadius: 0.0, bottomRadius: 0.2, height: 0.5))
  originNode.geometry?.firstMaterial?.diffuse.contents = color
  originNode.name = "ORIGIN"

  let transform = node.pivot
  originNode.position = SCNVector3(transform.m41, transform.m42, transform.m43)
  
  node.addChildNode(originNode)
}

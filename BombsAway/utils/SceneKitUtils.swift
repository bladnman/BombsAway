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

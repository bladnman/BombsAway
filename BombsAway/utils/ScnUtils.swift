//
//  SceneKitUtils.swift
//
//  Created by Maher, Matt on 2/10/21.
//
import SceneKit

class ScnUtils {
  static func measure(_ node: SCNNode) -> SCNVector3 {
    let (min, max) = node.boundingBox
    let w = Float(max.x - min.x)
    let h = Float(max.y - min.y)
    let l = Float(max.z - min.z)

    return SCNVector3(x: w, y: h, z: l)
  }
  static func measureToNodeSpace(_ node: SCNNode, to: SCNNode) -> SCNVector3 {
    let (minL, maxL) = node.boundingBox
    let min = node.convertPosition(minL, to: to)
    let max = node.convertPosition(maxL, to: to)
    let w = Float(max.x - min.x)
    let h = Float(max.y - min.y)
    let l = Float(max.z - min.z)

    return SCNVector3(x: w, y: h, z: l)
  }
  static func ceil(_ vector: SCNVector3) -> SCNVector3 {
    return SCNVector3(ceilf(vector.x), ceilf(vector.y), ceilf(vector.z))
  }
  static func rounded(_ vector: SCNVector3) -> SCNVector3 {
    return SCNVector3(vector.x.rounded(), vector.y.rounded(), vector.z.rounded())
  }
  static func makeText(text: String, depthOfText: CGFloat, color: UIColor, transparency: CGFloat) -> SCNNode {
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
  static func createOriginIndicator(_ node: SCNNode, color: UIColor = UIColor.green) {
    let originNode = SCNNode(geometry: SCNBox(width: 0.1, height: 5.0, length: 0.1, chamferRadius: 0.3))
    originNode.geometry?.firstMaterial?.diffuse.contents = color
    originNode.name = C_OBJ_NAME.origin
    originNode.position = SCNVector3(0, 0, 0)
    node.addChildNode(originNode)
    
  //  let gaussianBlur    = CIFilter(name: "CIGaussianBlur")
  //  gaussianBlur?.name  = "blur"
  //  gaussianBlur?.setValue(5, forKey: "inputRadius")
  //  originNode.filters        = [gaussianBlur] as? [CIFilter]
      
  //    let gaussianBlurFilter = CIFilter(name: "CIGaussianBlur")!
  //    gaussianBlurFilter.name = "blur"
  //    let pixellateFilter = CIFilter(name:"CIPixellate")!
  //    pixellateFilter.name = "pixellate"
  //    originNode.filters = [ pixellateFilter, gaussianBlurFilter ]
    
  }
  @discardableResult
  static func createPivotIndicator(_ node: SCNNode, color: UIColor = UIColor.green) -> SCNNode {
    let height = 0.3
    let pivotNode = SCNNode(geometry: SCNCone(topRadius: 0.0, bottomRadius: 0.1, height: CGFloat(height)))
    pivotNode.geometry?.firstMaterial?.diffuse.contents = color
    pivotNode.geometry?.firstMaterial?.transparency = 0.3

    pivotNode.pivot = SCNMatrix4MakeTranslation(0.0, -1 * Float(height / 2), 0.0)

    pivotNode.name = C_OBJ_NAME.pivot

    let transform = node.pivot
    pivotNode.position = SCNVector3(transform.m41, transform.m42, transform.m43)

    node.addChildNode(pivotNode)
    
    return node
  }
  static func deepCopyNode(_ node: SCNNode) -> SCNNode {
    
    // internal function for recurrsive calls
    func deepCopyInternals(_ node: SCNNode) {
      node.geometry = node.geometry?.copy() as? SCNGeometry
      if let g = node.geometry {
        node.geometry?.materials = g.materials.map { $0.copy() as! SCNMaterial }
      }
      for child in node.childNodes {
        deepCopyInternals(child)
      }
    }
    
    // CLONE main node (and all kids)
    // issue here is that both geometry and materials are linked
    // still. In our deepCopyNode we want new copies of everything
    let clone = node.clone()
    
    // we use this internal function to update both
    // geometry and materials, as well as process all children
    // this is the *deep* part of "deepCopy"
    deepCopyInternals(clone)
    
    return clone
  }
  static func getAncestorWithName(_ node: SCNNode?, name: String) -> SCNNode? {
    if node == nil { return nil }
    if node?.name == name { return node }
    return getAncestorWithName(node?.parent, name: name)
  }
  static func getChildWithName(_ children: [SCNNode]?, name: String) -> SCNNode? {
    if children == nil || children!.isEmpty { return nil }
    
    // first child with this name
    if let foundChild = children!.first(where: { $0.name == name }) {
      return foundChild
    }

    // search kids for this name
    for child in children! {
      return getChildWithName(child.childNodes, name: name)
    }
    return nil
  }
}


extension SCNVector3 {
  static func ==(vect1: SCNVector3, vect2: SCNVector3) -> Bool {
    return vect1.x == vect2.x &&
            vect1.y == vect2.y &&
            vect1.z == vect2.z
  }
}

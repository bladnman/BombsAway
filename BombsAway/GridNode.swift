//
//  GridNode.swift
//  BombsAway
//
//  Created by Maher, Matt on 2/28/21.
//

import SceneKit
import UIKit

class GridNode: SCNNode {
  let columns: Int
  let rows: Int
  let planeNode = SCNNode()
  
  var gridlineColor = UIColor.white
  var gridlineRadius = 0.05
  
  let top: CGFloat
  let right: CGFloat
  let bottom: CGFloat
  let left: CGFloat

  convenience init(_ columns: Int, _ rows: Int) {
    self.init(columns: columns, rows: rows)
  }

  init(columns: Int, rows: Int) {
    self.columns = columns
    self.rows = rows
    self.top = CGFloat(rows)
    self.right = CGFloat(columns)
    self.bottom = 0
    self.left = 0
    super.init()
    
    addChildNode(planeNode)

    drawGrid()
  }

  func drawGrid() {
    // set position of plane node
    planeNode.position = SCNVector3(-Float(columns/2), Float(0.05), -Float(rows/2))
    
    
//    _drawFrameWithPrimatives()
//    _drawFrameWithLines()
    _drawGridCells()
  }
  
  func _drawGridCells() {
    for c in 0..<columns {
      for r in 0..<rows {
        let geometry = SCNPlane(width: 1, height: 1)
        let node = SCNNode(geometry: geometry);

        node.position = SCNVector3(c, 0, r)
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        
        node.rotation = SCNVector4Make(1, 0, 0, (.pi/2 * 3))
        planeNode.addChildNode(node)
      }
    }
  }
  
  func _drawFrameWithPrimatives() {
    let height = CGFloat(1.0)
    // bottom line
    addChildNode(lineBetweenNodes(
      startPoint: SCNVector3(left, height, bottom),
      endPoint: SCNVector3(right, height, bottom)
    ))
    // top line
    addChildNode(lineBetweenNodes(
      startPoint: SCNVector3(left, height, top),
      endPoint: SCNVector3(right, height, top)
    ))
    // left line
    addChildNode(lineBetweenNodes(
      startPoint: SCNVector3(left, height, bottom),
      endPoint: SCNVector3(left, height, top)
    ))
    // right line
    addChildNode(lineBetweenNodes(
      startPoint: SCNVector3(right, height, bottom),
      endPoint: SCNVector3(right, height, top)
    ))
  }

  func _drawFrameWithLines() {
    let height = CGFloat(1.0)
    // bottom line
    addChildNode(getLineNode(
      startPoint: SCNVector3(left, height, bottom),
      endPoint: SCNVector3(right, height, bottom)
    ))
    // top line
    addChildNode(getLineNode(
      startPoint: SCNVector3(left, height, top),
      endPoint: SCNVector3(right, height, top)
    ))
    // left line
    addChildNode(getLineNode(
      startPoint: SCNVector3(left, height, bottom),
      endPoint: SCNVector3(left, height, top)
    ))
    // right line
    addChildNode(getLineNode(
      startPoint: SCNVector3(right, height, bottom),
      endPoint: SCNVector3(right, height, top)
    ))
  }
  
  func lineBetweenNodes(startPoint: SCNVector3, endPoint: SCNVector3) -> SCNNode {
    let vector = SCNVector3(startPoint.x - endPoint.x, startPoint.y - endPoint.y, startPoint.z - endPoint.z)
    let distance = sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
    let midPosition = SCNVector3(x: (startPoint.x + endPoint.x) / 2, y: (startPoint.y + endPoint.y) / 2, z: (startPoint.z + endPoint.z) / 2)

    let lineGeometry = SCNCylinder()
    lineGeometry.radius = CGFloat(gridlineRadius)
    lineGeometry.height = CGFloat(distance)
    lineGeometry.radialSegmentCount = 5
    
    if let material = lineGeometry.firstMaterial {
      material.diffuse.contents = gridlineColor
      material.emission.contents = UIColor.white
      material.emission.intensity = 0.8
      //    lineGeometry.firstMaterial!.shininess = 1.0
    }

    let lineNode = SCNNode(geometry: lineGeometry)
    lineNode.position = midPosition
    lineNode.look(at: endPoint, up: worldUp, localFront: lineNode.worldUp)
    return lineNode
  }

  func getLineNode(startPoint: SCNVector3, endPoint: SCNVector3) -> SCNNode {
    
    let vertices: [SCNVector3] = [startPoint, endPoint]
    let data = NSData(bytes: vertices, length: MemoryLayout<SCNVector3>.size * vertices.count) as Data
         
    let vertexSource = SCNGeometrySource(data: data,
                                         semantic: .vertex,
                                         vectorCount: vertices.count,
                                         usesFloatComponents: true,
                                         componentsPerVector: 3,
                                         bytesPerComponent: MemoryLayout<Float>.size,
                                         dataOffset: 0,
                                         dataStride: MemoryLayout<SCNVector3>.stride)
         
    let indices: [Int32] = [0, 1]
         
    let indexData = NSData(bytes: indices, length: MemoryLayout<Int32>.size * indices.count) as Data
         
    let element = SCNGeometryElement(data: indexData,
                                     primitiveType: .line,
                                     primitiveCount: indices.count / 2,
                                     bytesPerIndex: MemoryLayout<Int32>.size)
        
    let geometry = SCNGeometry(sources: [vertexSource], elements: [element])
    let lineNode = SCNNode(geometry: geometry)
    return lineNode
//    return geometry
  }
  @available(*, unavailable)

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}


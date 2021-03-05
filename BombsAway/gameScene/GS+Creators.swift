//
//  GS+Creators.swift
//  BombsAway
//
//  Created by Maher, Matt on 2/28/21.
//

import QuartzCore
import SceneKit
import SpriteKit
import UIKit

extension GameViewController {
  func createNewScene() {
    createSceneObjects()
    createFloor()
    createGrid()
    createCamera()
    createLights()
    createPlayer()
    createTestShips()
  }

  func resetGame() {
    scene.rootNode.enumerateChildNodes { node, _ in
      node.removeFromParentNode()
    }
    scene = nil
    
    createNewScene()
  }
  
  func createSceneObjects() {
    sceneView = (view as! SCNView)
    sceneView.delegate = self
    scene = SCNScene()
//    scene.physicsWorld.contactDelegate = self
    sceneView.present(scene, with: .fade(withDuration: 0.5), incomingPointOfView: nil, completionHandler: nil)
    
    sceneView.allowsCameraControl = true
    sceneView.showsStatistics = true
    sceneView.backgroundColor = UIColor.black
    
    sceneView.debugOptions = [
      //      SCNDebugOptions.showBoundingBoxes,
//      SCNDebugOptions.showWireframe,
//      SCNDebugOptions.renderAsWireframe,
//      SCNDebugOptions.showCreases,
    ]

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
    sceneView.addGestureRecognizer(tapGesture)
  }
  
  func createFloor() {
    let floor = SCNFloor()
    floor.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/grass.png")
    floor.firstMaterial?.diffuse.wrapS = .repeat
    floor.firstMaterial?.diffuse.wrapT = .repeat
    floor.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(12.5, 12.5, 12.5)
    floor.reflectivity = 0.4
    
    // MAKE IT AN OCEAN INSTEAD
    floor.firstMaterial?.emission.contents = UIColor.blue
    
    let floorNode = SCNNode(geometry: floor)
    scene.rootNode.addChildNode(floorNode)
  }

  func createCamera() {
    // create and add a camera to the scene
    let cameraNode = SCNNode()
    cameraNode.camera = SCNCamera()
    scene.rootNode.addChildNode(cameraNode)
    
    // place the camera
    cameraNode.position = SCNVector3(x: 1, y: 8, z: -5)
//    cameraNode.eulerAngles = SCNVector3(x: -toRadians(angle: 60), y: toRadians(angle: 20), z: 0)
    cameraNode.eulerAngles = SCNVector3(x: -toRadians(angle: 60), y: 0, z: 0)
  }

  func createLights() {
    // create and add a light to the scene
    let lightNode = SCNNode()
    lightNode.light = SCNLight()
    lightNode.light!.type = .omni
    lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
    scene.rootNode.addChildNode(lightNode)
    
    // create and add an ambient light to the scene
    let ambientLightNode = SCNNode()
    ambientLightNode.light = SCNLight()
    ambientLightNode.light!.type = .ambient
    ambientLightNode.light!.color = UIColor.darkGray
    scene.rootNode.addChildNode(ambientLightNode)
  }

  func createGrid() {
    gridNode = GridNode(columns: 10, rows: 10)
    scene.rootNode.addChildNode(gridNode)
  }
  
  func createPlayer() {
    let boxGeometry = SCNBox(width: 0.7, height: 0.1, length: 0.7, chamferRadius: 0.04)
    boxGeometry.firstMaterial?.diffuse.contents = UIColor.white
    boxGeometry.firstMaterial?.transparency = 0.8
    boxGeometry.firstMaterial?.emission.intensity = 0.8
    let node = SCNNode(geometry: boxGeometry)
    playerNode = node
    
    gridNode.moveToGridPoint(playerNode, column: 7, row: 2)
  }
  
  func createTestShips() {
    let boxGeometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.04)
    boxGeometry.firstMaterial?.diffuse.contents = UIColor.red
    boxGeometry.firstMaterial?.transparency = 0.1
    let node = SCNNode(geometry: boxGeometry)
    node.pivot = SCNMatrix4MakeTranslation(0.0, -0.5, 0.0)
    gridNode.moveToGridPoint(node, column: 2, row: 4)
    gridNode.moveToGridPoint(node.clone(), column: 2, row: 5)
    gridNode.moveToGridPoint(node.clone(), column: 2, row: 6)
    
    let boxGeometry2 = SCNBox(width: 3.0, height: 1.0, length: 1.0, chamferRadius: 0.04)
    boxGeometry2.firstMaterial?.diffuse.contents = UIColor.red
    boxGeometry2.firstMaterial?.transparency = 0.1
    let node2 = SCNNode(geometry: boxGeometry2)
    node2.pivot = SCNMatrix4MakeTranslation(0.0, -0.5, 0.0)
    gridNode.moveToGridPoint(node2, column: 5, row: 3)
    
    autoPositionShips()
  }
  
  func autoPositionShips() {
    autoPositionShipWithLength(3)
  }

  func autoPositionShipWithLength(_ length: Int) {
    if length > 5 || length < 2 {
      print("[M@] invalid length")
      return
    }
    
    let colors = [UIColor.green, UIColor.yellow, UIColor.orange, UIColor.systemPink]
    
    let boxGeometry = SCNBox(width: 1.0, height: 1.0, length: CGFloat(length), chamferRadius: 0.04)
    boxGeometry.firstMaterial?.diffuse.contents = colors.randomElement()
    boxGeometry.firstMaterial?.transparency = 0.1
    let node = SCNNode(geometry: boxGeometry)
    node.pivot = SCNMatrix4MakeTranslation(0.0, -0.5, 0.0) // move up to float
    
//    node.localRotate(by: SCNQuaternion(x: 0, y: 0.7071, z: 0, w: 0.7071))
//    node.rotation = SCNVector4Make(0, 1, 0, Float(Double.pi/2));
    var success = false
//    let rotations = getRotationArray()
//    let column = roll(10)
//    let row = roll(10)
    let rotations = [Float(180.0)]
    let column = 9
    let row = 9
    print("[M@] ===============================")
    print("[M@] POSITION [\(column), \(row)]")
    for angle in rotations {
      print("[M@] ATTEMPTING ANGLE: [\(angle)]")
      node.eulerAngles = SCNVector3Make(0.0, toRadians(angle: Float(angle)), 0.0)
      if gridNode.placeAtGridPointIfClear(node, column: column, row: row) {
        print("[M@] S U C C E S S   ANGLE: [\(angle)]")
        success = true
        break
      }
    }
    // DID NOT PLACE
    if success == false {
      print("[M@] no place for this... retrying")
    }
    print("[M@] ===============================")
  }
}

extension GameViewController: SCNSceneRendererDelegate {
  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//    updatePositions()
//    updateTraffic()
  }
}

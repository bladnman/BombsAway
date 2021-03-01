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
      SCNDebugOptions.showBoundingBoxes,
      SCNDebugOptions.showWireframe,
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
    cameraNode.position = SCNVector3(x: 0, y: 5, z: 15)
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
    let boxGeometry = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0.5)
    boxGeometry.firstMaterial?.diffuse.contents = UIColor.red
    let node = SCNNode(geometry: boxGeometry)
    scene.rootNode.addChildNode(node)
  }
}

extension GameViewController: SCNSceneRendererDelegate {
  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//    updatePositions()
//    updateTraffic()
  }
}

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
    createBoard()
    createCamera()
    createLights()
//    createPlayer()
    
    createOriginIndicator(scene.rootNode)
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
    floor.firstMaterial?.diffuse.contents = UIColor.fromHex("#2c3e50")
    floor.reflectivity = 0.0
    let floorNode = SCNNode(geometry: floor)
    floorNode.name = C_OBJ_NAME.worldFloor
    scene.rootNode.addChildNode(floorNode)
  }
  func createCamera() {
    let cameraNode = SCNNode()
    cameraNode.camera = SCNCamera()
    scene.rootNode.addChildNode(cameraNode)
    
    // place the camera
    cameraNode.position = SCNVector3(x: 1, y: 9, z: -6)
    cameraNode.eulerAngles = SCNVector3(x: -toRadians(angle: 70), y: 0, z: 0)
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
  func createBoard() {
    if let boardNode = self.boardNode {
      boardNode.removeAllActions()
      boardNode.removeFromParentNode()
    }
    boardNode = Board(sceneView: sceneView, columns: 10, rows: 10)
    scene.rootNode.addChildNode(boardNode)
    boardNode.position = SCNVector3(0, 0, -10)
  }
  func createPlayer() {
    let boxGeometry = SCNBox(width: 0.7, height: 0.1, length: 0.7, chamferRadius: 0.04)
    boxGeometry.firstMaterial?.diffuse.contents = UIColor.white
    boxGeometry.firstMaterial?.transparency = 0.8
    boxGeometry.firstMaterial?.emission.intensity = 0.8
    let node = SCNNode(geometry: boxGeometry)
    playerNode = node
    
    boardNode.moveToGridPoint(playerNode, GridPoint(7, 2))
  }
  func removeAllShips() {
    createBoard()
  }
}

extension GameViewController: SCNSceneRendererDelegate {
  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//    updatePositions()
//    updateTraffic()
  }
}

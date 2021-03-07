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
    
    createOriginIndicator(scene.rootNode)
    
    // DELAY THE KICK-OFF
    // hit tests are not happy without this
    let wait = SCNAction.wait(duration: 0.1)
    let run = SCNAction.run { _ in
        self.createTestShips()
    }
    let seq = SCNAction.sequence([wait, run])
    scene.rootNode.runAction(seq)
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
    floorNode.name = "floor"
    scene.rootNode.addChildNode(floorNode)
  }
  func createCamera() {
    // create and add a camera to the scene
    let cameraNode = SCNNode()
    cameraNode.camera = SCNCamera()
    scene.rootNode.addChildNode(cameraNode)
    
    // place the camera
    cameraNode.position = SCNVector3(x: 1, y: 8, z: -3)
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
    gridNode = Board(sceneView: sceneView, columns: 10, rows: 10)
    scene.rootNode.addChildNode(gridNode)
    gridNode.position = SCNVector3(0, 0, -10)
  }
  func createPlayer() {
    let boxGeometry = SCNBox(width: 0.7, height: 0.1, length: 0.7, chamferRadius: 0.04)
    boxGeometry.firstMaterial?.diffuse.contents = UIColor.white
    boxGeometry.firstMaterial?.transparency = 0.8
    boxGeometry.firstMaterial?.emission.intensity = 0.8
    let node = SCNNode(geometry: boxGeometry)
    playerNode = node
    
    gridNode.moveToGridPoint(playerNode, GridPoint(7, 2))
  }
  func createTestShips() {
    
    // KNOWN LARGE HORIZONTAL SHIP
//    gridNode.moveToGridPoint(makeShip(10, UIColor.white), GridPoint(5, 5))
    
//    let ship0 = makeShip(2)
//    gridNode.placeAtGridPointIfClear(ship0, GridPoint(3, 3))
//
//    let ship90 = makeShip(2)
//    ship90.eulerAngles = SCNVector3Make(0.0, toRadians(angle: Float(90)), 0.0)
//    gridNode.placeAtGridPointIfClear(ship90, GridPoint(8, 3))
//
//    let ship180 = makeShip(2)
//    ship180.eulerAngles = SCNVector3Make(0.0, toRadians(angle: Float(180)), 0.0)
//    gridNode.placeAtGridPointIfClear(ship180, GridPoint(3, 8))
//
//    let ship270 = makeShip(2)
//    ship270.eulerAngles = SCNVector3Make(0.0, toRadians(angle: Float(270)), 0.0)
//    gridNode.placeAtGridPointIfClear(ship270, GridPoint(8, 8))
    
    
    
    autoPositionShips()
    
  }
  func autoPositionShips() {
    for _ in 0...6 {
      autoPositionSingleShip()
    }
  }
  func autoPositionSingleShip() {
    autoPositionShipWithLength(roll(4) + 1)
  }
  func autoPositionShipWithLength(_ length: Int) {
    if length > 5 || length < 2 {
      print("[M@] invalid length")
      return
    }
    let node = makeShip(length)
    var success = false
    let rotations = getRotationArray()
    let column = roll(10)
    let row = roll(10)
    
//    let rotations = [Float(180.0)]
//    let column = 9
//    let row = 9
    
    print("[M@] ===============================")
    print("[M@] POSITION [\(column), \(row)] : LENGTH [\(length)]")
    for angle in rotations {
      print("[M@] ATTEMPTING ANGLE: [\(angle)]")
      node.eulerAngles = SCNVector3Make(0.0, toRadians(angle: Float(angle)), 0.0)
      if gridNode.placeAtGridPointIfClear(node, GridPoint(column, row)) {
        print("[M@] S U C C E S S   ANGLE: [\(angle)]")
        success = true
        break
      }
    }
    // DID NOT PLACE
    if success == false {
      print("[M@] no place for this... QUITTING")
    }
    print("[M@] ===============================")
  }
  func removeAllShips() {
    gridNode.removeAllShips()
  }
}

extension GameViewController: SCNSceneRendererDelegate {
  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//    updatePositions()
//    updateTraffic()
  }
}

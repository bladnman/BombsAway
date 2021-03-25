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
    createCamera()
    createLights()
    createBoard()
//    createOriginIndicator(scene.rootNode)
    createHUD()
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
//    scene = SCNScene()
    scene = SCNScene(named: "gamescenes.scnassets/MainScene.scn")
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
    camera = SCNNode()
    camera.camera = SCNCamera()
    scene.rootNode.addChildNode(camera)
    
    // place the camera
    camera.position = SCNVector3(x: 1, y: 9, z: -6)
    camera.eulerAngles = SCNVector3(x: -toRadians(angle: 70), y: 0, z: 0)
    
  }
  func createLights() {
    // create and add a light to the scene
//    let lightNode = SCNNode()
//    lightNode.light = SCNLight()
//    lightNode.light!.type = .omni
//    lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
//    scene.rootNode.addChildNode(lightNode)
//    
//    // create and add an ambient light to the scene
//    let ambientLightNode = SCNNode()
//    ambientLightNode.light = SCNLight()
//    ambientLightNode.light!.type = .ambient
//    ambientLightNode.light!.color = UIColor.darkGray
//    scene.rootNode.addChildNode(ambientLightNode)
  }
  func createBoard() {
    if let oldBoard = self.offenseBoard {
      oldBoard.removeAllActions()
      oldBoard.removeFromParentNode()
    }
    if let oldBoard = self.defendBoard {
      oldBoard.removeAllActions()
      oldBoard.removeFromParentNode()
    }

    // OFFENSE BOARD
    offenseBoard = Board(sceneView: sceneView,
                        columns: C_BOARD.Size.columns,
                        rows: C_BOARD.Size.rows,
                        type: BoardType.defense)
    
    // DEFEND BOARD
//    defendBoard = Board(sceneView: sceneView,
//                        columns: C_BOARD.Size.columns,
//                        rows: C_BOARD.Size.rows,
//                        type: BoardType.offense)

    if let holderNode = scene.rootNode.childNodes.first(where: { $0.name == "backBoardNode" }) {
      offenseBoard.position = SCNVector3(-0.5, 0, -0.5)
      offenseBoard.name = C_OBJ_NAME.attackBoard
      holderNode.addChildNode(offenseBoard)
    }
    

//    if let holderNode = scene.rootNode.childNodes.first(where: { $0.name == "bottomBoardNode" }) {
//      defendBoard.position = SCNVector3(-0.5, 0, -0.5)
//      defendBoard.name = C_OBJ_NAME.defendBoard
//      holderNode.addChildNode(defendBoard)
//    }
  }
  func removeAllShips() {
    createBoard()
  }
  func createHUD() {
    gameHUD = MainHUD(size: view.frame.size, delegate: self)
    sceneView.overlaySKScene = gameHUD
  }
}

extension GameViewController: SCNSceneRendererDelegate {
  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    // noop
  }
}

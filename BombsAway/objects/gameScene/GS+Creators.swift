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
    setupGameStore()
    createSceneObjects()
    createFloor()
    createCamera()
    createLights()
    createAllBoards()
    
    // MARK: todo... make hud not HAVE to be last
    lifeCy_beginTurn()
    createHUD()
    
  }
  func setupGameStore() {
    
    let names = [
      "Tom Cruise",
      "Trevor Noah",
      "John Sea-na",
      "Moby",
      "Natalie Port-man",
      "Catfish Stevens",
      "Fin Diesel",
      "Sailor Swift"
    ].shuffled()
    
    
    self.gameStore = GameStore()
    gameStore.gameSettings = GameSettings()
    let player1Store = PlayerStore(playerId: 0, playerName: names[0], gameSettings: gameStore.gameSettings)
    let player2Store = PlayerStore(playerId: 1, playerName: names[1], gameSettings: gameStore.gameSettings)
    
    // MARK: todo manage targeting better
    player1Store.targetPlayerId = 1
    player2Store.targetPlayerId = 0
    
    gameStore.addPlayerStore(player1Store)
    gameStore.addPlayerStore(player2Store)
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
    
    scene = SCNScene(named: "gamescenes.scnassets/MainScene.scn")
    sceneView.present(scene, with: .fade(withDuration: 0.5), incomingPointOfView: nil, completionHandler: nil)
    
    sceneView.backgroundColor = UIColor.black
    
    sceneView.showsStatistics = true
    sceneView.allowsCameraControl = true
//    sceneView.debugOptions = [
//        SCNDebugOptions.showBoundingBoxes,
//      SCNDebugOptions.showWireframe,
//      SCNDebugOptions.renderAsWireframe,
//      SCNDebugOptions.showCreases,
//    ]
    
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
  func createAllBoards() {
    removeAllBoards()
    if let currentPlayer = gameStore.currentTurnPlayerStore {
      
      
      farBoard = createBoardForPlayer(gameStore: gameStore,
                                      ownerId: currentPlayer.targetPlayerId,
                                      viewerId: currentPlayer.playerId)
      
      nearBoard = createBoardForPlayer(gameStore: gameStore,
                                       ownerId: currentPlayer.playerId,
                                       viewerId: currentPlayer.playerId)


      if let holderNode = scene.rootNode.childNodes.first(where: { $0.name == "backBoardNode" }) {
        farBoard.position = SCNVector3(-0.5, 0, -0.5)
        farBoard.name = C_OBJ_NAME.attackBoard
        holderNode.addChildNode(farBoard)
      }
      

      if let holderNode = scene.rootNode.childNodes.first(where: { $0.name == "bottomBoardNode" }) {
        nearBoard.position = SCNVector3(-0.5, 0, -0.5)
        nearBoard.name = C_OBJ_NAME.defendBoard
        holderNode.addChildNode(nearBoard)
      }
    }

  }
  func removeAllBoards() {
    guard farBoard != nil else {
      return
    }
    
    farBoard.removeFromParentNode()
    nearBoard.removeFromParentNode()
    farBoard = nil
    nearBoard = nil
//    for holderNodeName in ["backBoardNode", "bottomBoardNode"] {
//      if let holderNode = scene.rootNode.childNodes.first(where: { $0.name == holderNodeName }) {
//        holderNode.enumerateChildNodes( { node, _ in node.removeFromParentNode() })
//      }
//    }
  }
  func removeAllShips() {
    createNewScene()
  }
  func createHUD() {
    gameHUD = MainHUD(gameStore: gameStore, playerStore: gameStore.currentTurnPlayerStore!, size: view.frame.size, delegate: self)
    sceneView.overlaySKScene = gameHUD
  }
}


// MARK: GAME BOARD CREATION
extension GameViewController {
  func createBoardForPlayer(gameStore: GameStore, ownerId: Int, viewerId: Int) -> Board {
    let ownerBoardStore = gameStore.playerStoreForId(ownerId)!.boardStore
    
    // first time we want to add proper data
    // -ships, -spawn point, etc
    if ownerBoardStore.ships.count < 1 {
      createInitialBoardStoreData(boardStore: ownerBoardStore)
    }

    let board = Board(gameStore: gameStore,
                      ownerId: ownerId,
                      viewerId: viewerId,
                      delegate: self)
    
    ownerBoardStore.boardRef = board
    return board
  }
  func createNewShips(gameStore: GameStore, boardStore: BoardStore) {
    for shipLength in gameStore.gameSettings.shipSizeArray {
      createShipForLength(shipLength, boardStore: boardStore)
    }
  }
  func createShipForLength(_ length: Int, boardStore: BoardStore) {
    while true {
      if let shipData = validShipDataForLength(length, boardStore: boardStore) {
        boardStore.ships.append(shipData)
        return
      }
    }
  }
  func createInitialBoardStoreData(boardStore: BoardStore) {
    boardStore.spawnPoint = randomSpawnPointFor(boardSize: boardStore.boardSize)
    boardStore.spawnRect = spawnRectFor(spawnPoint: boardStore.spawnPoint)
    
    createNewShips(gameStore: gameStore, boardStore: boardStore)
    
    // MARK: TEMP PROBES
//    for _ in 1...5 {
//      let gp = GridPoint(roll(ownerBoardStore.boardSize.columns), roll(ownerBoardStore.boardSize.rows))
//      ownerBoardStore.probes.append(ProbeData(gridPoint: gp))
//    }
  }
  
  
  
  // utils
  func randomSpawnPointFor(boardSize: BoardSize) -> GridPoint {
    return GridPoint(roll(boardSize.columns-2) + 1, roll(boardSize.rows-2) + 1)
  }
  func spawnRectFor(spawnPoint: GridPoint) -> BoardRect {
    let firstGP = GridPoint(spawnPoint.column - 1, spawnPoint.row - 1)
    let lastGP = GridPoint(spawnPoint.column + 1, spawnPoint.row + 1)
    return BoardRect(firstGP: firstGP, lastGP: lastGP)
  }
  
  
  
  // MARK: SHIP CREATOR FUNTIONS
  // main board ship functions
  func validShipDataForLength(_ length: Int, boardStore: BoardStore) -> ShipData? {
    let startGP = GridPoint(roll(boardStore.boardSize.columns), roll(boardStore.boardSize.rows))

    // rotation points
    // these allow for negative rotation...
    // more work remains to make them work again
//    let rotations = [GridPoint( 1,0), GridPoint(0, 1),
//                     GridPoint(-1,0), GridPoint(0,-1)].shuffled()
    let rotations = [GridPoint(1,0), GridPoint(0,1)].shuffled()
    for rotationPoint in rotations {
      let columns = rotationPoint.column != 0 ? length * rotationPoint.column : 1
      let rows = rotationPoint.row != 0 ? length * rotationPoint.row : 1
      let shipBoardSize = BoardSize(columns: columns, rows: rows)
      let shipData = ShipData(startGridPoint: startGP, boardSize: shipBoardSize)
      
      // CELLS OUT OF RANGE - retry
      if !isBoardRangeWithinBoardSize(boardRange: shipData.boardRange, boardSize: boardStore.boardSize) {
        continue
      }
      
      // FELL INTO SPAWN RECT - retry
      if boardStore.spawnRect.containsAny(shipData.gridPoints) {
        continue
      }
      
      // SOME GP ALREADY OCCUPIED BY A SHIP - retry
      var isValidData = true
      for existingShipData in boardStore.ships {
        if existingShipData.containsAny(shipData.gridPoints) {
          isValidData = false
          break
        }
      }
      
      // SUCCESS!
      if isValidData {
        return shipData
      }
    }
    return nil
  }
  func isBoardRangeWithinBoardSize(boardRange: BoardRange, boardSize: BoardSize) -> Bool {
    if boardRange.columnRange.min()! < 1 || boardRange.rowRange.min()! < 1 {
      return false
    }

    if boardRange.columnRange.max()! > boardSize.columns || boardRange.rowRange.max()! > boardSize.rows {
      return false
    }
    
    return true
  }

  
}

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
    createHUD()
  }
  func setupGameStore() {
    self.gameStore = GameStore()
    gameStore.gameSettings = GameSettings()
    let player1Store = PlayerStore(playerId: 1, playerName: "Tom Cruise", gameSettings: gameStore.gameSettings)
    let player2Store = PlayerStore(playerId: 2, playerName: "Trevor Noah", gameSettings: gameStore.gameSettings)
    
    gameStore.playerStores.append(player1Store)
    gameStore.playerStores.append(player2Store)
    
    gameStore.startNextTurn()
    
    // first player in the store is always us
    self.player = gameStore.playerStores.first!.player
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
    if let oldBoard = self.offenseBoard {
      oldBoard.removeAllActions()
      oldBoard.removeFromParentNode()
    }
    if let oldBoard = self.defenseBoard {
      oldBoard.removeAllActions()
      oldBoard.removeFromParentNode()
    }

    // MARK: programatically draw boards here
    defenseBoard = createBoard(gameStore: gameStore, ownerId: 1)
    offenseBoard = createBoard(gameStore: gameStore, ownerId: 2)

    if let holderNode = scene.rootNode.childNodes.first(where: { $0.name == "backBoardNode" }) {
      offenseBoard.position = SCNVector3(-0.5, 0, -0.5)
      offenseBoard.name = C_OBJ_NAME.attackBoard
      holderNode.addChildNode(offenseBoard)
    }
    

    if let holderNode = scene.rootNode.childNodes.first(where: { $0.name == "bottomBoardNode" }) {
      defenseBoard.position = SCNVector3(-0.5, 0, -0.5)
      defenseBoard.name = C_OBJ_NAME.defendBoard
      holderNode.addChildNode(defenseBoard)
    }
  }
  func removeAllShips() {
    createNewScene()
  }
  func createHUD() {
    gameHUD = MainHUD(size: view.frame.size, delegate: self)
    sceneView.overlaySKScene = gameHUD
    gameHUD?.player = gameStore.playerStoreForId(currentTurn.playerId)?.player
  }
}


// MARK: GAME BOARD CREATION
extension GameViewController {
  func createBoard(gameStore: GameStore, ownerId: Int) -> Board {
    let boardStore = gameStore.playerStoreForId(ownerId)!.boardStore
    
    // first generate spawn point info
    boardStore.spawnPoint = randomSpawnPointFor(boardSize: boardStore.boardSize)
    boardStore.spawnRect = spawnRectFor(spawnPoint: boardStore.spawnPoint)
    
    
    createNewShips(gameStore: gameStore, boardStore: boardStore)
    
    // MARK: TEMP PROBES
    for _ in 1...5 {
      let gp = GridPoint(roll(boardStore.boardSize.columns), roll(boardStore.boardSize.rows))
      boardStore.probes.append(ProbeData(gridPoint: gp))
    }

    
    
    // MARK: THIS IS LAST
    let board = Board(gameStore: gameStore,
                      ownerId: ownerId,
                      viewerId: player.playerId,
                      delegate: self)
    
    
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

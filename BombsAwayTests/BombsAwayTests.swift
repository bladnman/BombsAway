//
//  BombsAwayTests.swift
//  BombsAwayTests
//
//  Created by Maher, Matt on 3/25/21.
//

import SceneKit
import XCTest

class BombsAwayTests: XCTestCase {
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testExample() throws {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
  }

  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    measure {
      // Put the code you want to measure the time of here.
    }
  }
}

@testable import BombsAway
class BoardRangeTests: XCTestCase {
  func testCreatingRanges() {
    var boardRange: BoardRange

    boardRange = BoardRange(GridPoint(11, 11),
                            BoardSize(columns: 5, rows: 1))
    XCTAssertEqual(boardRange.columnRange, 11...15)
    XCTAssertEqual(boardRange.rowRange, 11...11)
    
    
    boardRange = BoardRange(GridPoint(10, 10),
                            BoardSize(columns: 5, rows: -1))
    XCTAssertEqual(boardRange.columnRange, 10...14)
    XCTAssertEqual(boardRange.rowRange, 10...10)
    
    
    boardRange = BoardRange(GridPoint(10, 10),
                            BoardSize(columns: -5, rows: -1))
    XCTAssertEqual(boardRange.columnRange, 6...10)
    XCTAssertEqual(boardRange.rowRange, 10...10)
    
  }
}

@testable import BombsAway
class BoardSizeTests: XCTestCase {
  func test_boardSizesColRows() {
    var boardSize: BoardSize

    boardSize = BoardSize(columns: 5, rows: 0)
    XCTAssertEqual(boardSize.columns, 5)
    XCTAssertEqual(boardSize.rows, 0)
  }

  func test_boardSizesVectors() {
    var boardSize: BoardSize

    
    boardSize = BoardSize(SCNVector3(1, 0, 1))
    XCTAssertEqual(boardSize.columns, 1)
    XCTAssertEqual(boardSize.rows, 1)
    
    
    boardSize = BoardSize(SCNVector3(10, 0, 0))
    XCTAssertEqual(boardSize.columns, 10)
    XCTAssertEqual(boardSize.rows, 0)
  }
  func test_gridPointsForRange() {
    let startGP = GridPoint(2, 2)
    let boardRange = BoardRange(startGP,
                            BoardSize(columns: 2, rows: 2))
    let gridPoints = gridPointsFor(boardRange: boardRange)
    XCTAssertEqual(gridPoints.contains(where: {$0.column == 2 && $0.row == 2}), true)
    XCTAssertEqual(gridPoints.contains(where: {$0.column == 2 && $0.row == 3}), true)
    XCTAssertEqual(gridPoints.contains(where: {$0.column == 3 && $0.row == 2}), true)
    XCTAssertEqual(gridPoints.contains(where: {$0.column == 3 && $0.row == 3}), true)
  }

}


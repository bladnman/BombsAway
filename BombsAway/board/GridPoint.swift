//
//  GridPoint.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/4/21.
//

import SceneKit

struct GridPoint {
  var column: Int
  var row: Int
  
  init(_ column: Int, _ row: Int) {
    self.column = column
    self.row = row
  }
  init(_ column: Float, _ row: Float) {
    self.column = Int(column)
    self.row = Int(row)
  }
  init(_ column: CGFloat, _ row: CGFloat) {
    self.column = Int(column)
    self.row = Int(row)
  }
  init(_ column: Double, _ row: Double) {
    self.column = Int(column)
    self.row = Int(row)
  }
  init(_ vector: SCNVector3) {
    self.column = Int(vector.x)
    self.row = Int(vector.z)
  }
  
  var isZero: Bool {
    get {
      return column == 0 && row == 0
    }
  }
  
  static var zero: GridPoint {
    get {
      return GridPoint(0, 0)
    }
  }
}
extension GridPoint {
  static func +(gp1: GridPoint, gp2: GridPoint) -> GridPoint {
    return GridPoint(
      gp1.column + gp2.column,
      gp1.row + gp2.row
    )
  }
  static func -(gp1: GridPoint, gp2: GridPoint) -> GridPoint {
    return GridPoint(
      gp1.column - gp2.column,
      gp1.row - gp2.row
    )
  }
}

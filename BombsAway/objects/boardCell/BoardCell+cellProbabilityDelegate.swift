//
//  BoardCell+cellProbability.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/15/21.
//

import UIKit

extension BoardCell: CellProbabilityDelegate {
  func probHasSolidShip() -> Bool {
    return self.hasSolidShip
  }
  func probHasCollectible() -> Bool {
    return self.hasCollectible
  }
  func probHasProbe() -> Bool {
    return self.hasProbe
  }
  func probGetSurroundingProbeCount() -> Int {
    return delegate?.bcellGetSurroundingProbeCount(gridPoint) ?? 0
  }
}

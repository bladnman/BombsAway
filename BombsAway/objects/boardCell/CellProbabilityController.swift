//
//  CellProbability.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/15/21.
//

import UIKit
protocol CellProbabilityDelegate {
  func probHasSolidShip() -> Bool
  func probHasCollectible() -> Bool
  func probHasProbe() -> Bool
  func probGetSurroundingProbeCount() -> Int
}
class CellProbabilityController {
  let delegate: CellProbabilityDelegate!
  
  init(_ delegate: CellProbabilityDelegate) {
    self.delegate = delegate
  }
  
  func getFloorColor() -> UIColor {
    let hasOwnProbe = delegate.probHasProbe()
    let neighborProbeCount = delegate.probGetSurroundingProbeCount()
    
    // only if we have something to show (ship or collectible)
    if delegate.probHasSolidShip() || delegate.probHasCollectible() {
      
      var probabilty = 50; // defaults at 50/50 chance (we do nothing for 50% chance)
      
      probabilty += neighborProbeCount * 10 // 10% per neighboring probe
      
      // if there is a probe in our cell, tell the truth
      if hasOwnProbe {
        probabilty += 100
      }

      if probabilty >= 80 { return C_COLOR.red }
      if probabilty >= 70 { return C_COLOR.orange }
      if probabilty >= 60 { return C_COLOR.yellowLight }

      // no probes - "hidden"
      if C_DBG.showHiddenShipFloors {
        return UIColor.fromHex("#22374a")
      }
    }

    return UIColor.fromHex("#34495e")
  }
  func getFloorColorOriginalStrategy() -> UIColor {
    let hasOwnProbe = delegate.probHasProbe()
    let neighborProbeCount = delegate.probGetSurroundingProbeCount()
    
    // only if we have something to show (ship or collectible)
    if delegate.probHasSolidShip() || delegate.probHasCollectible() {
      
      var probabilty = 50; // defaults at 50/50 chance (we do nothing for 50% chance)
      
      probabilty += neighborProbeCount * 10 // 10% per neighboring probe
      
      // if there is a probe in our cell, tell the truth
      if hasOwnProbe {
        probabilty += 100
      }
      
      probabilty = min(100, probabilty) // clamp to 100%

      // you have to have better than a coin-flip
      // for us to even roll to show things
      if probabilty > 50 {
        // probability is the "chance"
        // we will tell the truth
        if chance(probabilty) {
          if probabilty > 90 { return C_COLOR.red }
          if probabilty > 80 { return C_COLOR.orange }
          if probabilty > 70 { return C_COLOR.yellow }
          if probabilty > 60 { return C_COLOR.yellowLight }
          return UIColor.red
        }
      }

      // no probes - "hidden"
      return UIColor.fromHex("#22374a")
    }

    return UIColor.fromHex("#34495e")
  }
}

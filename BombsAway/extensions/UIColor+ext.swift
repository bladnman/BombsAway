//
//  UIColor+ext.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/5/21.
//

import UIKit

extension UIColor {
  class func randomColor(randomAlpha: Bool = false) -> UIColor {
    let redValue = CGFloat(arc4random_uniform(255)) / 255.0
    let greenValue = CGFloat(arc4random_uniform(255)) / 255.0
    let blueValue = CGFloat(arc4random_uniform(255)) / 255.0
    let alphaValue = randomAlpha ? CGFloat(arc4random_uniform(255)) / 255.0 : 1

    return UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: alphaValue)
  }
}

//
//  UIColor+ext.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/5/21.
//

import UIKit

extension UIColor {
  static func fromHex(_ hex: String, alpha: CGFloat = 1.0) -> UIColor {
      var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
      
      if hexFormatted.hasPrefix("#") {
          hexFormatted = String(hexFormatted.dropFirst())
      }
      
      assert(hexFormatted.count == 6, "Invalid hex code used.")
      
      var rgbValue: UInt64 = 0
      Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
      
      return UIColor(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: alpha)
  }
  class func randomColor(randomAlpha: Bool = false) -> UIColor {
    let redValue = CGFloat(arc4random_uniform(255)) / 255.0
    let greenValue = CGFloat(arc4random_uniform(255)) / 255.0
    let blueValue = CGFloat(arc4random_uniform(255)) / 255.0
    let alphaValue = randomAlpha ? CGFloat(arc4random_uniform(255)) / 255.0 : 1

    return UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: alphaValue)
  }
}

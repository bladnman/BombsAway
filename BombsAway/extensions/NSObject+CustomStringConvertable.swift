//
//  NSObject+CustomStringConvertable.swift
//  BombsAway
//
//  Created by Maher, Matt on 3/23/21.
//

import Foundation
extension CustomStringConvertible {
  var description: String {
    var description: String = ""
    description = "[\(type(of: self))]: \n"
    let selfMirror = Mirror(reflecting: self)
    for child in selfMirror.children {
      if let propertyName = child.label {
        description += "    - \(propertyName): \(child.value)\n"
      }
    }
    return description
  }
}

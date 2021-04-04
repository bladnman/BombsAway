//
//  SpriteKitButton.swift
//  Super Indie Runner
//
//  Created by Maher, Matt on 1/24/21.
//

import SpriteKit

class LabelButton: SKSpriteNode {

  let labelNode: SKLabelNode!
  var text: String
  var action: (Int) -> ()
  var onDown: ((Int) -> ())?
  var onUp: ((Int) -> ())?
  var index: Int
  private var state: SpriteKitButtonState = .up {
    didSet {
      if state != oldValue {
        switch state {
        case .down:
          self.alpha = 0.75
          onDown?(index)
        default:
          self.alpha = 1.0
          onUp?(index)
        }
      }
    }
  }
  init(text: String, size: CGSize, action: @escaping (Int) -> (), index: Int ) {
    self.action = action
    self.index = index
    self.text = text
    labelNode = SKLabelNode(fontNamed: "Futura-CondensedExtraBold")
    labelNode.text = text
    labelNode.verticalAlignmentMode = .center
    let labelSize = labelNode.frame.size;
    let buttonSize = CGSize(width: labelSize.width + labelSize.width * 0.3 ,
                            height: labelSize.height + labelSize.height * 1.0)
    super.init(texture: nil, color: UIColor.clear, size: buttonSize)
    
    isUserInteractionEnabled = true
    addChild(labelNode)

    self.color = UIColor.clear
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    state = .down


    // MARK: THIS IS NOT CORRECT!
    // we need to test if it was our button that was released
    // for now, we will just do the action on PRESS
    action(index)
  }
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    let touch: UITouch = touches.first! as UITouch
    let location: CGPoint = touch.location(in: self)
    
    if self.contains(location) {
      state = .down
    } else {
      state = .up
    }
  }
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    let touch: UITouch = touches.first! as UITouch
    touchDoneAtLocation(touch.location(in: self))
  }
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    let touch: UITouch = touches.first! as UITouch
    touchDoneAtLocation(touch.location(in: self))
  }
  func touchDoneAtLocation(_ location: CGPoint) {
    state = .up
    
    // MARK: THIS IS NOT CORRECT!
    // we need to test if it was our button that was released
//    action(index)
//    print("[M@] self.size", self.size)
//    print("[M@] self.frame", self.frame)
//    print("[M@] location", location )
//    let touchedNode = self.atPoint(location)
//    if touchedNode == labelNode || touchedNode == self {
//      print("[M@] *****   IT WAS WE")
//    }
  }
}

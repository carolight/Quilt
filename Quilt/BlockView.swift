//
//  BlockView.swift
//  Quilt
//
//  Created by Caroline Begbie on 2/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import UIKit

protocol BlockViewDelegate {
  func blockViewShouldShowFabric(blockView:BlockView, location:CGPoint)
}

class BlockView: UIView {

  var image:UIImage!
  var delegate: BlockViewDelegate? = nil

  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    var tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
    self.addGestureRecognizer(tapGesture)
  }

    override func drawRect(rect: CGRect) {
      
      image.drawInRect(rect)
    }

  
  func handleTap(gesture: UITapGestureRecognizer) {
    println("tapped block")
    let location = gesture.locationInView(self)
    delegate?.blockViewShouldShowFabric(self, location:location)

  }
}

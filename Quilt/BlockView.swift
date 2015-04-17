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
  
  var patches:[Patch] = []
  var patchColors:[Int] = []
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    var tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
    self.addGestureRecognizer(tapGesture)
  }

    override func drawRect(rect: CGRect) {
      
      image.drawInRect(rect)
      let width = self.bounds.width
      let height = self.bounds.height
      
      UIColor.redColor().setStroke()
      
      for (index, patch) in enumerate(patches) {
        var first = true
        var path = UIBezierPath()
        for point in patch.points {
          let location = CGPoint(x: point.x * width, y:point.y * height)
          if first {
            path.moveToPoint(location)
            first = false
          } else {
            path.addLineToPoint(location)
          }
        }
        if patch.color == UIColor.blueColor() {
        switch patchColors[index] {
        case 0:
          patch.color = UIColor.lightGrayColor()
        case 1:
          patch.color = UIColor.grayColor()
        case 2:
          patch.color = UIColor.darkGrayColor()
        case 3:
          patch.color = UIColor.purpleColor()
        case 4:
          patch.color = UIColor.yellowColor()
        case 5:
          patch.color = UIColor.greenColor()
        default:
          patch.color = UIColor.cyanColor()
        }
        }
        path.closePath()
        path.lineWidth = 5.0
        patch.color.setFill()
        path.fill()
        path.stroke()
        patch.path = path
        
      }
    }

  
  func handleTap(gesture: UITapGestureRecognizer) {
    let location = gesture.locationInView(self)
    delegate?.blockViewShouldShowFabric(self, location:location)
    

  }
}

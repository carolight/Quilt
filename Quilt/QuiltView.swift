//
//  QuiltView.swift
//  Quilt
//
//  Created by Caroline Begbie on 1/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import UIKit

protocol QuiltViewDelegate {
  func quiltViewShouldShowBlock(quiltView:QuiltView, location:CGPoint)
}

class QuiltView: UIView {

  var image:UIImage!
  var delegate: QuiltViewDelegate? = nil
  var paths:[UIBezierPath] = []
  
  let blockSize = CGSize(width: 100, height: 100)
  let blocksAcross = 6
  let blocksDown = 9
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    var tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
    self.addGestureRecognizer(tapGesture)
  }
  
    override func drawRect(rect: CGRect) {
      println("drawrect")
      image.drawInRect(rect)
      
      for path in paths {
        path.lineWidth = 4.0
        UIColor.yellowColor().setStroke()
        path.stroke()
        
      }
//      for i in 0..<blocksAcross {
//        for j in 0..<blocksDown {
//          let column = CGFloat(i)
//          let row = CGFloat(j)
//          let originX = column * blockSize.width
//          let originY = row * blockSize.height
//          
//          var path = UIBezierPath(rect: CGRect(origin: CGPoint(x: originX, y: originY), size: blockSize))
//    
//          UIColor.yellowColor().setStroke()
//          path.lineWidth = 4.0
//          path.stroke()
//          
//          paths.append(path)
//          
//        }
//      }
    }
  
  func handleTap(gesture:UITapGestureRecognizer) {
    println("tap")
    let location = gesture.locationInView(self)
    for path in paths {
      if path.containsPoint(location) {
        println(path.bounds)
        
        delegate?.quiltViewShouldShowBlock(self, location:location)
      }
    }
  }

}

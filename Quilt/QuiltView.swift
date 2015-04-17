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
  
  let displayBlockSize = CGSize(width: 100, height: 100)
  var blockSize = CGSizeZero
  let blocksAcross = 6
  let blocksDown = 9
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    var tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
    self.addGestureRecognizer(tapGesture)
  }
  
    override func drawRect(rect: CGRect) {
      image.drawInRect(rect)
      
      for path in paths {
        var pathCopy = path.copy() as! UIBezierPath
        var scale:CGFloat = self.bounds.width / image.size.width
        var transform = CGAffineTransformIdentity
        transform = CGAffineTransformScale(transform, scale, scale)
        pathCopy.applyTransform(transform)
        pathCopy.lineWidth = 4.0
        UIColor.blackColor().setStroke()
        pathCopy.stroke()
    }
  }
  
  func handleTap(gesture:UITapGestureRecognizer) {
    var location = gesture.locationInView(self)
    var scale:CGFloat = self.bounds.width / image.size.width
    location.x = location.x / scale
    location.y = location.y / scale
    
    for path in paths {
      if path.containsPoint(location) {
        delegate?.quiltViewShouldShowBlock(self, location:location)
      }
    }
  }

}

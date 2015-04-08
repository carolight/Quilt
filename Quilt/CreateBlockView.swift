//
//  CreateBlockView.swift
//  Quilt
//
//  Created by Caroline Begbie on 7/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import UIKit

class CreateBlockView: UIView {
  
  var patch:Patch?
  var patches:[Patch] = []
  var result = CGPointZero

  var allowEdit = false // Only allow if new path is being created
  
  override func drawRect(rect: CGRect) {
    var column:CGFloat = 0
    var row:CGFloat = 0
    var columnWidth:CGFloat = 30
    var circleWidth:CGFloat = 5
    var circleRect = CGRect(origin: CGPointZero, size: CGSize(width: circleWidth, height: circleWidth))
    circleRect.origin.x -= circleWidth / 2
    circleRect.origin.y -= circleWidth / 2
    UIColor.blackColor().setFill()

    while row < self.bounds.height {
      while column < self.bounds.width {
        let path = UIBezierPath(ovalInRect: circleRect)
        path.fill()
        circleRect.origin.x += columnWidth
        column = circleRect.origin.x
      }
      circleRect.origin.x = -(circleWidth / 2)
      circleRect.origin.y += columnWidth
      row = circleRect.origin.y
      column = circleRect.origin.x
    }
    
    //draw patches
    UIColor.orangeColor().setFill()
    UIColor.blueColor().setStroke()
    for patch in patches {
      var first = true
      var width = self.bounds.width
      var path = UIBezierPath()
      for point in patch.points {
        let location = CGPoint(x: point.x * width, y: point.y * width)
        if first {
          path.moveToPoint(location)
          first = false
        } else {
          path.addLineToPoint(location)
        }
      }
      path.closePath()
      path.fill()
      path.stroke()
    }
  }
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    if !allowEdit {
      return
    }
    let touch = touches.anyObject() as UITouch
    let location = touch.locationInView(self)
    let width = self.bounds.width
    
    var resultX = location.x / width
    var resultY = location.y / width
    
    resultX = ceil(resultX * 100)
    resultY = ceil(resultY * 100)
    
    result = CGPoint(x: resultX / 100, y: resultY / 100)
    
    println(result)
  }
  
  override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
    if !allowEdit {
      return
    }

    let touch = touches.anyObject() as UITouch
    let location = touch.locationInView(self)
    let width = self.bounds.width
    
    var resultX = location.x / width
    var resultY = location.y / width
    
    resultX = ceil(resultX * 100)
    resultY = ceil(resultY * 100)
    
    result = CGPoint(x: resultX / 100, y: resultY / 100)
    
    println(result)
  }
  
  override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
    
     if !allowEdit {
      return
    }

    if let patch = patch {
      println("Final result: \(result)")
      patch.points.append(result)
    }

  }
  
  
}

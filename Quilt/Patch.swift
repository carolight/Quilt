//
//  Patch.swift
//  Quilt
//
//  Created by Caroline Begbie on 24/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import Foundation

class Patch {
  var points:[CGPoint] = []
  var color: UIColor = UIColor.blueColor()
  var path: UIBezierPath = UIBezierPath() //sometimes path is available instead of points
  var fabric: Fabric? = nil
  
  func createPath(blockSize:CGSize) -> UIBezierPath {
    var first = true
    path = UIBezierPath()
    for point in points {
      let locationX = point.x * blockSize.width
      let locationY = point.y * blockSize.height
      if first {
        path.moveToPoint(CGPoint(x: locationX, y: locationY))
        first = false
      } else {
        path.addLineToPoint(CGPoint(x: locationX, y: locationY))
      }
    }
    path.closePath()
    return path
  }
  
  func archivePoints() -> [String] {
    var array = [String]()
    
    for point in points {
      let stringPoint = NSStringFromCGPoint(point)
      array.append(stringPoint)
    }
    return array
  }
  
  func unarchivePoints(stringPoints:[String]) {
    points = []
    for stringPoint in stringPoints {
      let point = CGPointFromString(stringPoint)
      points.append(point)
    }
  }
  
}


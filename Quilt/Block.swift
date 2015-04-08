//
//  Block.swift
//  Quilt
//
//  Created by Caroline Begbie on 3/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import Foundation
import UIKit

class Block  {
  var name:String = " "
  var image:UIImage? = nil
  var patches:[Patch] = []
  var patchColors:[Int] = []
  var documentID:String? = nil
  
  func createImage() -> UIImage? {
    var blockSize = CGSize(width: 100, height: 100)
    UIGraphicsBeginImageContextWithOptions(blockSize, true, 0)
    
    let context = UIGraphicsGetCurrentContext()
    
    UIColor.whiteColor().setFill()
    CGContextFillRect(context, CGRect(origin: CGPointZero, size: blockSize))
    
    for patch in patches {
      var first = true
      var path = patch.createPath(blockSize)
      UIColor.blackColor().setStroke()
      path.lineWidth = 2.0
      path.stroke()
    }
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image
  }
  
  func save() {
    let properties = ["type": "Block",
                      "name": name]
    
    let document = database.createDocument()
    var error:NSError?
    
    if document.putProperties(properties, error: &error) == nil {
      println("couldn't save new item \(error?.localizedDescription)")
    }
    
    var newRevision = document.currentRevision.createRevision()
    let imageData = UIImagePNGRepresentation(image)
    newRevision.setAttachmentNamed("image.png", withContentType: "image/png", content: imageData)
    assert(newRevision.save(&error) != nil)
    
    //TODO: - the points must be saved, not the paths, as the points are resizable
    
    newRevision = document.currentRevision.createRevision()
    
    var newPatches:[[String]] = []
    var newPatch:[String] = []
    for patch in patches {
      newPatch = []
      for point in patch.points {
        let newPoint = NSStringFromCGPoint(point)
        newPatch.append(newPoint)
      }
      newPatches.append(newPatch)
    }
    if newPatches.count > 0 {
      let patchesData = NSKeyedArchiver.archivedDataWithRootObject(newPatches)
      newRevision.setAttachmentNamed("patchPoints", withContentType: "CGPoint", content: patchesData)
      assert(newRevision.save(&error) != nil)
    }
//    var paths:[UIBezierPath] = []
//    for patch in patches {
//      let path = patch.createPath(CGSize(width: 100, height: 100))
//      paths.append(path)
//    }
//    if paths.count > 0 {
//      let pathsData = NSKeyedArchiver.archivedDataWithRootObject(paths)
//      newRevision.setAttachmentNamed("patchPaths", withContentType: "UIBezierPath", content: pathsData)
//      assert(newRevision.save(&error) != nil)
//    }
    
    newRevision = document.currentRevision.createRevision()
    let colorData = NSKeyedArchiver.archivedDataWithRootObject(patchColors)
    newRevision.setAttachmentNamed("patchColors", withContentType: "Int", content: colorData)
    assert(newRevision.save(&error) != nil)
    
    documentID = document.documentID

  }

  func load(documentID:String) {
    self.documentID = documentID
    let document = database.documentWithID(documentID)
    if let name = document["name"] as? String {
      self.name = name
    }
    
    let revision = document.currentRevision
    if let imageData = revision.attachmentNamed("image.png") {
      if let image = UIImage(data: imageData.content, scale: UIScreen.mainScreen().scale) {
        self.image = image
      }
    }
    
//    if let pathsData = revision.attachmentNamed("patchPaths") {
//      if let data = pathsData.content {
//        if let paths = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [UIBezierPath] {
//          patches = []
//          for path in paths {
//            let patch = Patch()
//            patch.path = path
//            patches.append(patch)
//          }
//        }
//        println("loaded \(patches.count) patches")
//      }
//    }
    
    if let patchesData = revision.attachmentNamed("patchPoints") {
      if let data = patchesData.content {
        if let patches = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [[String]] {
          for patch in patches {
            let newPatch = Patch()
            newPatch.points = []
            for point in patch {
              let newPoint = CGPointFromString(point)
              newPatch.points.append(newPoint)
            }
            self.patches.append(newPatch)
          }
        }
      }
      println("loaded \(patches.count) patches")
    }
    
    if let colorData = revision.attachmentNamed("patchColors") {
      if let data = colorData.content {
        if let colors = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [Int] {
          patchColors = colors
        }
      }
      println("loaded \(patchColors.count) colors")
    }
  }

}

class Patch {
  var points:[CGPoint] = []
  var color: UIColor = UIColor.blueColor()
  var path: UIBezierPath = UIBezierPath() //sometimes path is available instead of points
  
  func createPath(blockSize:CGSize) -> UIBezierPath {
    var first = true
    var path = UIBezierPath()
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
}
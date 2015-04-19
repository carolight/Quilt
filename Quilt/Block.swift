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
  var library: Bool = true
  
  func createImage(size: CGSize) -> UIImage? {
//    var blockSize = CGSize(width: 100, height: 100)
    let blockSize = size
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
    println("Block save")
    let properties = ["type": "Block",
                      "library": library,
                      "name": name]
    
    let document = database.createDocument()
    var error:NSError?
    
    if document.putProperties(properties as [NSObject : AnyObject], error: &error) == nil {
      println("couldn't save new item \(error?.localizedDescription)")
    }
    println("Block now saved")
    
    if let image = image {
      var newRevision = document.currentRevision.createRevision()
      let imageData = UIImagePNGRepresentation(image)
      newRevision.setAttachmentNamed("image.png", withContentType: "image/png", content: imageData)
      assert(newRevision.save(&error) != nil)
    } else {
      assertionFailure("Block Image missing")
    }
    
    var newRevision = document.currentRevision.createRevision()
    
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
    
    newRevision = document.currentRevision.createRevision()
    let colorData = NSKeyedArchiver.archivedDataWithRootObject(patchColors)
    newRevision.setAttachmentNamed("patchColors", withContentType: "Int", content: colorData)
    assert(newRevision.save(&error) != nil)
    
    documentID = document.documentID

  }
  
  
  func update(documentID:String) {
    println("updating Quilt: \(documentID)")
    var error:NSError?
    let document = database.documentWithID(documentID)
    let properties = NSMutableDictionary(dictionary: document.properties)
    
    properties["type"] = "Block"
    properties["name"] = name
    properties["library"] = library
    
    if document.putProperties(properties as [NSObject : AnyObject], error: &error) == nil {
      println("couldn't save new item \(error?.localizedDescription)")
    }
    
    if let image = image {
      var newRevision = document.currentRevision.createRevision()
      let imageData = UIImagePNGRepresentation(image)
      newRevision.setAttachmentNamed("image.png", withContentType: "image/png", content: imageData)
      assert(newRevision.save(&error) != nil)
    } else {
      assertionFailure("Block Image missing")
    }
    
    var newRevision = document.currentRevision.createRevision()
    
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
    
    newRevision = document.currentRevision.createRevision()
    let colorData = NSKeyedArchiver.archivedDataWithRootObject(patchColors)
    newRevision.setAttachmentNamed("patchColors", withContentType: "Int", content: colorData)
    assert(newRevision.save(&error) != nil)
  }


  func load(documentID:String) {
    self.documentID = documentID
    let document = database.documentWithID(documentID)
    if let name = document["name"] as? String {
      self.name = name
    }
    
    if let library = document["library"] as? Bool {
      self.library = library
    }
    
    let revision = document.currentRevision
    if let imageData = revision.attachmentNamed("image.png") {
      if let image = UIImage(data: imageData.content, scale: UIScreen.mainScreen().scale) {
        self.image = image
      }
    }
    
    
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

  func saveToPlist() {
    
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
    let documentsDirectory = paths[0] as! NSString
    let path = documentsDirectory.stringByAppendingPathComponent("Block-\(name).plist")
    
    let dictionary = NSMutableDictionary()
    dictionary["name"] = name

    var newPatches:[[String]] = []
    var newPatch:[String] = []
    for patch in patches {
      newPatch = []
      for point in patch.points {
        var newStringPoint:String = NSStringFromCGPoint(point)
        newPatch.append(newStringPoint)
      }
      newPatches.append(newPatch)
    }
    dictionary["patches"] = newPatches
    dictionary["patchColors"] = patchColors
    
    dictionary.writeToFile(path, atomically: false)
  }
  
  func loadFromDictionary(dictionary:NSDictionary) {
    name = dictionary["name"] as! String
    library = true
    if let imageData = dictionary["image"] as? NSData {
      if let image = UIImage(data: imageData, scale: UIScreen.mainScreen().scale) {
        self.image = image
      }
    }
    if let patches = dictionary["patches"] as? [[String]] {
      for patch in patches {
        let newPatch = Patch()
        for stringPoint in patch {
          let point = CGPointFromString(stringPoint)
          newPatch.points.append(point)
        }
        self.patches.append(newPatch)
      }
    }
    self.patchColors = dictionary["patchColors"] as! [Int]
    self.image = createImage(CGSize(width: 100, height: 100))
  }
  
  func buildLibraryQuiltBlockImage(size:CGSize, scheme:Scheme, showPaths:Bool) -> UIImage? {
    
    scheme.loadFabricImages()
    
    UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
    let context = UIGraphicsGetCurrentContext()
    UIColor.whiteColor().setFill()
    CGContextFillRect(context, CGRect(origin: CGPointZero, size: size))
    
    for (index, patch) in enumerate(self.patches) {
      var first = true
      var path = patch.createPath(size)
      let colorIndex = self.patchColors[index]
      let index = colorIndex % scheme.fabricImages.count
      let image = scheme.fabricImages[index]
      UIColor(patternImage: image).setFill()
      
      path.fill()
      
      if showPaths {
        UIColor.blackColor().setStroke()
        path.lineWidth = 2.0
        path.stroke()
      }
    }
    
    var image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
  }

}

class Patch {
  var points:[CGPoint] = []
  var color: UIColor = UIColor.blueColor()
  var path: UIBezierPath = UIBezierPath() //sometimes path is available instead of points
  var fabric: Fabric? = nil
  
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
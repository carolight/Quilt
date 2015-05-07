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
  
  var type: CollectionType = .Block
  
  var documentID:String? = nil
  var name:String = " "
  var image:UIImage? = nil
  var patches:[Patch] = []
  var patchColors:[Int] = []
  var library: Bool = true

  //User Block
  var quiltID:String? = nil
  var _quilt:Quilt? = nil
  var quilt:Quilt? {
    get {
      if let quiltID = self.quiltID {
        if _quilt == nil {
          _quilt = Quilt()
          _quilt!.load(quiltID)
        }
      } else {
        return nil
      }
      return _quilt!
    }
    set {
      _quilt = newValue
      quiltID = newValue?.documentID
    }
  }
  
  var blockFabrics:[String] = []

  func copy() -> Block {
    let newBlock = Block()
    newBlock.name = self.name
    newBlock.image = self.image
    newBlock.patches = self.patches
    newBlock.patchColors = self.patchColors
    newBlock.library = self.library
    newBlock.quiltID = self.quiltID
    newBlock.quilt = self.quilt
    newBlock.blockFabrics = self.blockFabrics
    return newBlock
  }
  
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

  func buildUserQuiltBlockImage(size:CGSize, showPaths:Bool) -> UIImage? {
    
    var fabricsPath = NSBundle.mainBundle().resourcePath!
    fabricsPath = fabricsPath.stringByAppendingString("/fabrics/")
    var fabricImages:[UIImage] = []
    for fabric in blockFabrics {
      let filename = fabricsPath.stringByAppendingPathComponent(fabric)
      if let image = UIImage(contentsOfFile: filename) {
        fabricImages.append(image)
      }
    }
    
      UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
      let context = UIGraphicsGetCurrentContext()
      UIColor.whiteColor().setFill()
      CGContextFillRect(context, CGRect(origin: CGPointZero, size: size))

    //TODO: This code is duplicated in BlockView
      var useSchemeFabrics = false
      if self.patchColors.count > fabricImages.count {
        useSchemeFabrics = true
        let scheme = gSelectedScheme!
        if scheme.fabricImages.count < scheme.fabrics.count {
          scheme.loadFabricImages()
        }
      }
      
      for (index, patch) in enumerate(self.patches) {
        var first = true
        var path = patch.createPath(size)
        let colorIndex = self.patchColors[index]
        
        var image:UIImage? = nil
        if useSchemeFabrics {
          let scheme = gSelectedScheme!
          let index = colorIndex % scheme.fabricImages.count
          image = scheme.fabricImages[index]
        } else {
          let index = colorIndex % fabricImages.count
          image = fabricImages[index]
        }
        if let image = image {
          UIColor(patternImage: image).setFill()
          path.fill()
        }
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


extension Block: DatabaseProtocol {
  
  func archivePatches() -> [[String]] {
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
    return newPatches
  }
  
  func save() {
    println("Block save")
    
    let newPatches = archivePatches()
    
    let properties: NSDictionary
    if self.library {
      properties = ["type": "Block",
        "library": library,
        "patchColors":patchColors,
        "patchPoints": newPatches,
        "name": name]
    } else {

      assert(quiltID != nil, "No Quilt ID")
      if let quiltDocumentID = quiltID {
        properties = ["type": "Block",
          "name": name,
          "library": library,
          "patchColors":patchColors,
          "patchPoints": newPatches,
          "quiltID": quiltDocumentID,
          "blockFabrics": blockFabrics]
      } else {
        properties = [:]
      }
    }
    let document = gSave(properties)
    var error:NSError?
    
    if image == nil {
      if library {
        var scheme = quilt?.scheme
        if scheme == nil {
          scheme = gSelectedScheme
        }
        image = buildLibraryQuiltBlockImage(CGSize(width: 100, height: 100), scheme: scheme!, showPaths: true)
      } else {
        image = buildUserQuiltBlockImage(CGSize(width: 100, height: 100), showPaths: false)
      }
    }
    if let image = image {
      var newRevision = document.currentRevision.createRevision()
      let imageData = UIImagePNGRepresentation(image)
      newRevision.setAttachmentNamed("image.png", withContentType: "image/png", content: imageData)
      assert(newRevision.save(&error) != nil)
    } else {
      assertionFailure("Block Image missing")
    }
    
//    var newRevision = document.currentRevision.createRevision()
    
//    var newPatches:[[String]] = []
//    var newPatch:[String] = []
//    for patch in patches {
//      newPatch = []
//      for point in patch.points {
//        let newPoint = NSStringFromCGPoint(point)
//        newPatch.append(newPoint)
//      }
//      newPatches.append(newPatch)
//    }
//    if newPatches.count > 0 {
//      let patchesData = NSKeyedArchiver.archivedDataWithRootObject(newPatches)
//      newRevision.setAttachmentNamed("patchPoints", withContentType: "CGPoint", content: patchesData)
//      assert(newRevision.save(&error) != nil)
//    }
    
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
  
    properties["patchColors"] = patchColors
    properties["patchPoints"] = archivePatches()
    
    if !library {
      properties["quiltID"] = quiltID
      properties["blockFabrics"] = blockFabrics
    }

    gUpdate(document, properties)
    
    if let image = image {
      var newRevision = document.currentRevision.createRevision()
      let imageData = UIImagePNGRepresentation(image)
      newRevision.setAttachmentNamed("image.png", withContentType: "image/png", content: imageData)
      assert(newRevision.save(&error) != nil)
    } else {
      assertionFailure("Block Image missing")
    }
    
//    var newRevision = document.currentRevision.createRevision()
//    
//    var newPatches:[[String]] = []
//    var newPatch:[String] = []
//    for patch in patches {
//      newPatch = []
//      for point in patch.points {
//        let newPoint = NSStringFromCGPoint(point)
//        newPatch.append(newPoint)
//      }
//      newPatches.append(newPatch)
//    }
//    if newPatches.count > 0 {
//      let patchesData = NSKeyedArchiver.archivedDataWithRootObject(newPatches)
//      newRevision.setAttachmentNamed("patchPoints", withContentType: "CGPoint", content: patchesData)
//      assert(newRevision.save(&error) != nil)
//    }
    
  }

  func loadPatches(patchPoints:[[String]]) {
    for patch in patchPoints {
      let newPatch = Patch()
      newPatch.points = []
      for point in patch {
        let newPoint = CGPointFromString(point)
        newPatch.points.append(newPoint)
      }
      self.patches.append(newPatch)
    }
    println("loaded \(patches.count) patches")
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
    
    if !library {
      if let
        quiltID = document["quiltID"] as? String,
        blockFabrics = document["blockFabrics"] as? [String]
      {
        self.quiltID = quiltID
        self.blockFabrics = blockFabrics
      }
    }
    
    if let patchColors = document["patchColors"] as? [Int] {
      self.patchColors = patchColors
    }
    if let patchPoints = document["patchPoints"] as? [[String]] {
      loadPatches(patchPoints)
    }
    
    if let revision = document.currentRevision {
      if let imageData = revision.attachmentNamed("image.png") {
        if let image = UIImage(data: imageData.content, scale: UIScreen.mainScreen().scale) {
          self.image = image
        }
      }
    }
    
    
//    if let patchesData = revision.attachmentNamed("patchPoints") {
//      if let data = patchesData.content {
//        if let patches = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [[String]] {
//          for patch in patches {
//            let newPatch = Patch()
//            newPatch.points = []
//            for point in patch {
//              let newPoint = CGPointFromString(point)
//              newPatch.points.append(newPoint)
//            }
//            self.patches.append(newPatch)
//          }
//        }
//      }
//      println("loaded \(patches.count) patches")
//    }
//  }
  }
}
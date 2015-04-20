/*//
//  QuiltBlocks.swift
//  Quilt
//
//  Created by Caroline Begbie on 8/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import Foundation

class QuiltBlock {

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
      _quilt = quilt
    }
  }

  var block:Block? {
    get {
      if let blockID = self.blockID {
        if _block == nil {
          _block = Block()
          _block!.load(blockID)
        }
      } else {
        return nil
      }
      return _block!
    }
    set {
      _block = block
    }
  }

  
  var _quilt:Quilt? = nil
  var _block:Block? = nil {
    didSet {
      blockFabrics = []
      if let block = block {
        name = "My \(block.name)"
        for patch in block.patches {
          blockFabrics.append(" ")
        }
      }
    }
    
  }
  var row:Int = 0
  var column:Int = 0
  var blockFabrics:[String] = []
  
  var outline: UIBezierPath? = nil
  var image: UIImage? = nil
  var name:String = "User Block"
  var quiltID:String? = nil
  var blockID:String? = nil
  var library = false
  var documentID:String? = nil
  
  func save() {
    println("QuiltBlock save")
    if let quiltDocumentID = quiltID {
      if let blockDocumentID = blockID {
        
        let properties:NSDictionary = ["type": "Block",
          "quiltID": quiltDocumentID,
          "blockID": blockDocumentID,
          "name": name,
          "column": column,
          "row": row,
          "library": library,
          "blockFabrics": blockFabrics]
        
        let document = database.createDocument()
        var error:NSError?
        
        if document.putProperties(properties as [NSObject : AnyObject], error: &error) == nil {
          println("couldn't save new item \(error?.localizedDescription)")
        }
        if let image = image {
          var newRevision = document.currentRevision.createRevision()
          let imageData = UIImagePNGRepresentation(image)
          newRevision.setAttachmentNamed("image.png", withContentType: "image/png", content: imageData)
          assert(newRevision.save(&error) != nil)
        } else {
          assertionFailure("QuiltBlock image missing")
        }
        documentID = document.documentID
      }
    } else {
      assertionFailure("Quilt Block Document IDs are nil")
    }
    
  }
  
  func update(documentID:String) {
    
    var error:NSError?
    let document = database.documentWithID(documentID)
    let properties = NSMutableDictionary(dictionary: document.properties)
    
    properties["type"] = "Block"
    properties["quiltID"] = quiltID
    properties["blockID"] = blockID
    properties["column"] = column
    properties["row"] = row
    properties["library"] = library
    properties["blockFabrics"] = blockFabrics
    
    if document.putProperties(properties as [NSObject : AnyObject], error: &error) == nil {
      println("couldn't save new item \(error?.localizedDescription)")
    }
    
    var newRevision = document.currentRevision.createRevision()
    let imageData = UIImagePNGRepresentation(image)
    newRevision.setAttachmentNamed("image.png", withContentType: "image/png", content: imageData)
    assert(newRevision.save(&error) != nil)
    
  }
  
  func load(documentID:String) {
    self.documentID = documentID
    
    let document = database.documentWithID(documentID)

    if let
      quiltID = document["quiltID"] as? String,
      blockID = document["blockID"] as? String,
      blockFabrics = document["blockFabrics"] as? [String]
    {
      
      self.quiltID = quiltID
      self.blockID = blockID
      self.blockFabrics = blockFabrics
    }
    
    if let name = document["name"] as? String {
      self.name = name
    }
    
    if let library = document["library"] as? Bool {
      self.library = library
    }
    
    let revision = document.currentRevision
    if let revision = revision {
      if let imageData = revision.attachmentNamed("image.png") {
        if let image = UIImage(data: imageData.content, scale: UIScreen.mainScreen().scale) {
          self.image = image
        }
      }
    }
    
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

    if let block = block {
      UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
      let context = UIGraphicsGetCurrentContext()
      UIColor.whiteColor().setFill()
      CGContextFillRect(context, CGRect(origin: CGPointZero, size: size))
      
      var useSchemeFabrics = false
      if block.patchColors.count > fabricImages.count {
        useSchemeFabrics = true
        let scheme = gSelectedScheme
        if scheme.fabricImages.count < scheme.fabrics.count {
          scheme.loadFabricImages()
        }
      }
      
      for (index, patch) in enumerate(block.patches) {
        var first = true
        var path = patch.createPath(size)
        let colorIndex = block.patchColors[index]
        
        var image:UIImage? = nil
        if useSchemeFabrics {
          let scheme = gSelectedScheme
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
    return nil
  }
  
  
  
  
}

*/
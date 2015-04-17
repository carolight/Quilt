//
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
        for patch in block.patches {
          blockFabrics.append(" ")
        }
      }
    }
    
  }
  var row:Int = 0
  var column:Int = 0
  var image:UIImage? = nil
  var blockFabrics:[String] = []
  
  var documentID: String? = nil
  var outline: UIBezierPath? = nil
  
  var quiltID:String? = nil
  var blockID:String? = nil
  
  func save() {
    println("QuiltBlock save")
    if let quiltDocumentID = quiltID {
      if let blockDocumentID = blockID {
        
        let properties:NSDictionary = ["type": "QB",
          "quiltID": quiltDocumentID,
          "blockID": blockDocumentID,
          "column": column,
          "row": row,
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
    let retrievedProperties = document.properties as NSDictionary
    var properties = retrievedProperties.copy() as! NSMutableDictionary
    
    properties["type"] = "QB"
    properties["quiltID"] = quiltID
    properties["blockID"] = blockID
    properties["column"] = column
    properties["row"] = row
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
//      let quilt = Quilt()
//      quilt.load(quiltID)
//      self.quilt = quilt
//      
//      let block = Block()
//      block.load(blockID)
//      self.block = block
      
      self.quiltID = quiltID
      self.blockID = blockID
      self.blockFabrics = blockFabrics
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
  
  func buildLibraryQuiltBlockImage(size:CGSize, scheme:Scheme) -> UIImage? {

    scheme.loadFabricImages()
    
    if let block = self.block {
      UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
      let context = UIGraphicsGetCurrentContext()
      UIColor.whiteColor().setFill()
      CGContextFillRect(context, CGRect(origin: CGPointZero, size: size))
      
      for (index, patch) in enumerate(block.patches) {
        var first = true
        var path = patch.createPath(size)
        
        let colorIndex = block.patchColors[index]
        
        let index = colorIndex % scheme.fabricImages.count
        
        let image = scheme.fabricImages[index]
        
        UIColor(patternImage: image).setFill()

        
        path.fill()
      }
      
      
      var image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      return image
    }
    return nil
  }
  
  
}
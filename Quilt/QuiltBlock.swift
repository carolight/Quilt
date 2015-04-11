//
//  QuiltBlocks.swift
//  Quilt
//
//  Created by Caroline Begbie on 8/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import Foundation

class QuiltBlock {
  var quilt:Quilt? = nil
  var block:Block? = nil {
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
  
  
  func save() {
    if let quiltDocumentID = quilt?.documentID {
      if let blockDocumentID = block?.documentID {
        
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
        
        var newRevision = document.currentRevision.createRevision()
        let imageData = UIImagePNGRepresentation(image)
        newRevision.setAttachmentNamed("image.png", withContentType: "image/png", content: imageData)
        assert(newRevision.save(&error) != nil)
        
        documentID = document.documentID
      }
    }
    
  }
  
  func update(documentID:String) {
    
    var error:NSError?
    let document = database.documentWithID(documentID)
    let retrievedProperties = document.properties as NSDictionary
    var properties = retrievedProperties.copy() as! NSMutableDictionary
    
    properties["type"] = "QB"
    properties["quiltID"] = quilt?.documentID
    properties["blockID"] = block?.documentID
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
    
    if let quiltID = document["quiltID"] as? String {
      let quilt = Quilt()
      quilt.load(quiltID)
      self.quilt = quilt
    }
    
    if let blockID = document["blockID"] as? String {
      let block = Block()
      block.load(blockID)
      self.block = block
    }
    
    if let column = document["column"] as? Int {
      self.column = column
    }
    if let row = document["row"] as? Int {
      self.row = row
    }
    
    if let blockFabrics = document["blockFabrics"] as? [String] {
      self.blockFabrics = blockFabrics
    }
    
    let revision = document.currentRevision
    if let imageData = revision.attachmentNamed("image.png") {
      if let image = UIImage(data: imageData.content, scale: UIScreen.mainScreen().scale) {
        self.image = image
      }
    }
    
  }
  
  
}
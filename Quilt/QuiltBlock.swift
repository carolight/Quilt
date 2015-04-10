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
  var block:Block? = nil
  var row:Int = 0
  var column:Int = 0
  var image:UIImage? = nil
  
  var documentID: String? = nil
  
  
  func save() {
    if let quilt = quilt {
      if let block = block {
        
        let properties:NSDictionary = ["type": "QB",
          "quiltID": quilt.documentID!,
          "blockID": block.documentID!,
          "column": column,
          "row": row]
        
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
    
    let revision = document.currentRevision
    if let imageData = revision.attachmentNamed("image.png") {
      if let image = UIImage(data: imageData.content, scale: UIScreen.mainScreen().scale) {
        self.image = image
      }
    }
    
  }

  
}
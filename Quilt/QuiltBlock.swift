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
  
  var documentID: String?
  
  init(quilt:Quilt, block:Block) {
    self.quilt = quilt
    self.block = block
  }
  
  func save() {
    if let quilt = quilt {
      if let block = block {
        
        let properties:NSDictionary = ["quiltID": quilt.documentID!,
          "blockID": block.documentID!,
          "column": column,
          "row": row]
        
        let document = database.createDocument()
        var error:NSError?
        
        if document.putProperties(properties, error: &error) == nil {
          println("couldn't save new item \(error?.localizedDescription)")
        }
        
        documentID = document.documentID
      }
    }
    
  }
  
}
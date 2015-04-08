//
//  Quilt.swift
//  Quilt
//
//  Created by Caroline Begbie on 3/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import Foundation
import UIKit

class Quilt {
  var name:String = " "
  var image:UIImage? = nil
  var blockPaths: [UIBezierPath] = []
  var blockSize:CGSize = CGSizeZero
  var quiltSize:CGSize = CGSizeZero
  var library:Bool = false
  var documentID:String? = nil
  
  func save() {
    let properties = ["type": "Quilt",
                      "name": name,
                      "blocksAcross": 5,
                      "blocksDown":9,
                      "library":library]

    let document = database.createDocument()
    var error:NSError?
    
    if document.putProperties(properties, error: &error) == nil {
      println("couldn't save new item \(error?.localizedDescription)")
    }
    
    println("Saving image size: \(image?.size)")
    println("scale: \(image?.scale)")

    var newRevision = document.currentRevision.createRevision()
    let imageData = UIImagePNGRepresentation(image)
    newRevision.setAttachmentNamed("image.png", withContentType: "image/png", content: imageData)
    assert(newRevision.save(&error) != nil)

    newRevision = document.currentRevision.createRevision()
    let blockPathsData = NSKeyedArchiver.archivedDataWithRootObject(blockPaths)
    newRevision.setAttachmentNamed("blockPaths", withContentType: "UIBezierPath", content: blockPathsData)
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
    
    println("Loading image size: \(image?.size)")
    println("scale: \(image?.scale)")

    if let blockPathsData = revision.attachmentNamed("blockPaths") {
      if let data = blockPathsData.content {
        if let array = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [UIBezierPath] {
          self.blockPaths = array
          println("WOW")
        }
      }
    }
  }
  
}
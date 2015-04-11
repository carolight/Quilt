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
  var blocksAcross: Int = 5 {
    didSet {
      self.resetLinkedQuilts(oldValue, oldBlocksDown: self.blocksDown)
    }
  }
  var blocksDown: Int = 9 {
    didSet {
      self.resetLinkedQuilts(self.blocksAcross, oldBlocksDown: oldValue)
    }
  }
  
  //A two dimensional array of the quilt blocks
  //preallocated and pointing at the block used
  //If it's a user quilt, it's a user block
  var quiltBlocksID:[[String]] = [[String]]()
  
  func resetLinkedQuilts(oldBlocksAcross: Int, oldBlocksDown:Int) {
    var newQuiltBlocksID = [[String]]()
    for column in 0..<blocksAcross {
      let array = [String](count:blocksDown, repeatedValue: " ")
      newQuiltBlocksID.append(array)
    }
    for column in 0..<blocksAcross {
      for row in 0..<blocksDown {
        if column < oldBlocksAcross && row < oldBlocksDown {
          newQuiltBlocksID[column][row] = quiltBlocksID[column][row]
        }
      }
    }
    quiltBlocksID = newQuiltBlocksID
  }
  
  func copy() -> Quilt {
    var newQuilt = Quilt()
    newQuilt.name = self.name
    newQuilt.image = self.image
    newQuilt.blockPaths = self.blockPaths
    newQuilt.blockSize = self.blockSize
    newQuilt.quiltSize = self.quiltSize
    newQuilt.library = self.library
    newQuilt.documentID = self.documentID
    newQuilt.blocksAcross = self.blocksAcross
    newQuilt.blocksDown = self.blocksDown
    
    //need to save to get document id to save in user blocks
    newQuilt.save()
    
    //copy quilt blocks to user blocks
    let query = database.viewNamed("quiltBlocks").createQuery()
    var error:NSError?
    let result = query.run(&error)
    while let row = result?.nextRow() {
      let quiltBlock = QuiltBlock()
      quiltBlock.load(row.documentID)
      let newQuiltBlock = QuiltBlock()
      newQuiltBlock.quilt = newQuilt
      newQuiltBlock.block = quiltBlock.block
      newQuiltBlock.column = quiltBlock.column
      newQuiltBlock.row = quiltBlock.row
      newQuiltBlock.blockFabrics = quiltBlock.blockFabrics
      newQuiltBlock.save()

      //update quilt matrix to point at new block
      for column in 0..<blocksAcross {
        for row in 0..<blocksDown {
          if self.quiltBlocksID[column][row] == quiltBlock.documentID {
            self.quiltBlocksID[column][row] = newQuiltBlock.documentID!
          }
        }
      }
    }
    
    //newQuilt is updated with other details on return
    return newQuilt
  }
  
  func save() {
    let properties = ["type": "Quilt",
      "name": name,
      "blocksAcross": blocksAcross,
      "blocksDown": blocksDown,
      "library":library,
      "quiltBlocksID": quiltBlocksID]
    

    
    
    let document = database.createDocument()
    var error:NSError?
    
    if document.putProperties(properties as [NSObject : AnyObject], error: &error) == nil {
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
    
    if let quiltBlocksID = document["quiltBlocksID"] as? [[String]] {
      self.quiltBlocksID = quiltBlocksID
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
  
  func update(documentID:String) {
    
    var error:NSError?
    let document = database.documentWithID(documentID)
    let retrievedProperties = document.properties as NSDictionary
    var properties = retrievedProperties.copy() as! NSMutableDictionary
    
    properties["type"] = "Quilt"
    properties["name"] = name
    properties["blocksAcross"] = blocksAcross
    properties["blocksDown"] = blocksDown
    properties["library"] = library
    properties["quiltBlocksID"] = quiltBlocksID
    
    if document.putProperties(properties as [NSObject : AnyObject], error: &error) == nil {
      println("couldn't save new item \(error?.localizedDescription)")
    }
    
    var newRevision = document.currentRevision.createRevision()
    let imageData = UIImagePNGRepresentation(image)
    newRevision.setAttachmentNamed("image.png", withContentType: "image/png", content: imageData)
    assert(newRevision.save(&error) != nil)
    
    newRevision = document.currentRevision.createRevision()
    let blockPathsData = NSKeyedArchiver.archivedDataWithRootObject(blockPaths)
    newRevision.setAttachmentNamed("blockPaths", withContentType: "UIBezierPath", content: blockPathsData)
    assert(newRevision.save(&error) != nil)
    
  }
  
}
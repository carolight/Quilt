//
//  Quilt.swift
//  Quilt
//
//  Created by Caroline Begbie on 3/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import Foundation
import UIKit

enum quiltCellState {
  case Empty, Block, UserBlock
}

struct QuiltMatrix {
  let row: Int, column: Int
  
  init(row:Int, column: Int) {
    self.row = row
    self.column = column
  }
}

class Quilt {
  private var blocks: [String]
  
  var type:CollectionType = .Quilt

  var name:String = " "
  var image:UIImage? = nil
  var blockSize:CGSize = CGSizeZero
  var quiltSize:CGSize = CGSizeZero
  var library:Bool = false
  var schemeID:String? = nil
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
//  var quiltBlocksID:[[String]] = [[String]]()
  
  init() {
//    for row in 0..<blocksDown {
//      let array = [String](count:blocksAcross, repeatedValue: " ")
//      quiltBlocksID.append(array)
//    }
    
    self.blocks = Array(count: blocksAcross * blocksDown, repeatedValue: " ")
    
  }
  
  subscript(location: QuiltMatrix) -> String {
    get {
        assert(isWithinBounds(location), "row or column index is out of bounds")
      return self.blocks[location.row * blocksAcross + location.column]
    }
    set {
      assert(isWithinBounds(location), "row or column index is out of bounds")
      self.blocks[location.row * blocksAcross + location.column] = newValue
    }
  }
  
  subscript(row: Int, column: Int) -> String {
    get {
      return self[QuiltMatrix(row: row, column: column)]
    }
    set {
      self[QuiltMatrix(row: row, column: column)] = newValue
    }
  }
  
  func isWithinBounds(location: QuiltMatrix) -> Bool {
    return location.row >= 0 && location.row < blocksDown &&
            location.column >= 0 && location.column < blocksAcross
  }
  
  func cellVisitor(function: (QuiltMatrix) -> ()) {
    for row in 0..<blocksDown {
      for column in 0..<blocksAcross {
        let location = QuiltMatrix(row: row, column: column)
        function(location)
      }
    }
  }
  
  func clearQuilt() {
    cellVisitor { self[$0] = " " }
  }
  
  func resetLinkedQuilts(oldBlocksAcross: Int, oldBlocksDown:Int) {
    return
    
    //TODO: when blocks across or down are changed, array needs to be
    //initialised
//    var newQuiltBlocksID = [[String]]()
//    for row in 0..<blocksDown {
//      let array = [String](count:blocksAcross, repeatedValue: " ")
//      newQuiltBlocksID.append(array)
//    }
//    for row in 0..<blocksDown {
//      for column in 0..<blocksAcross {
//        if column < oldBlocksAcross && row < oldBlocksDown {
//          newQuiltBlocksID[row][column] = quiltBlocksID[row][column]
//        }
//      }
//    }
//    quiltBlocksID = newQuiltBlocksID
  }
  
  func copy(scheme:Scheme) -> Quilt {
    var newQuilt = Quilt()
    newQuilt.name = self.name
    newQuilt.image = self.image
    newQuilt.blockSize = self.blockSize
    newQuilt.quiltSize = self.quiltSize
    newQuilt.library = self.library
    newQuilt.documentID = self.documentID
    newQuilt.schemeID = scheme.documentID
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
      newQuiltBlock.quiltID = newQuilt.documentID
      newQuiltBlock.blockID = quiltBlock.blockID
      newQuiltBlock.column = quiltBlock.column
      newQuiltBlock.row = quiltBlock.row
      newQuiltBlock.blockFabrics = quiltBlock.blockFabrics
      
      let blockSize = CGSize(width: 100, height: 100)
      newQuiltBlock.image = newQuiltBlock.block?.buildLibraryQuiltBlockImage(blockSize, scheme: scheme, showPaths: false)
      
      newQuiltBlock.save()
      
      //update quilt matrix to point at new block
      cellVisitor {
        if self[$0] == quiltBlock.documentID {
          newQuilt[$0] = newQuiltBlock.documentID!
        }
      }
//      for row in 0..<blocksDown {
//        for column in 0..<blocksAcross {
//          if self.quiltBlocksID[row][column] == quiltBlock.documentID {
//            newQuilt.quiltBlocksID[row][column] = newQuiltBlock.documentID!
//          }
//        }
//      }
    }
    
    //newQuilt is updated with other details on return
    return newQuilt
  }
  
//  func save() {
//    if let schemeID = schemeID {
//      println("saving Quilt")
//      let properties = ["type": "Quilt",
//        "name": name,
//        "blocksAcross": blocksAcross,
//        "blocksDown": blocksDown,
//        "library":library,
//        "schemeID":schemeID,
////        "quiltBlocksID": quiltBlocksID,
//        "blocks": blocks
//      ]
//      
//      
//      
//      
//      let document = database.createDocument()
//      var error:NSError?
//      
//      if document.putProperties(properties as [NSObject : AnyObject], error: &error) == nil {
//        println("couldn't save new item \(error?.localizedDescription)")
//      }
//      
//      //TODO: - might not need quilt image
//      
//      var newRevision = document.currentRevision.createRevision()
//      let imageData = UIImagePNGRepresentation(image)
//      newRevision.setAttachmentNamed("image.png", withContentType: "image/png", content: imageData)
//      assert(newRevision.save(&error) != nil)
//      
//      newRevision = document.currentRevision.createRevision()
//      let blockPathsData = NSKeyedArchiver.archivedDataWithRootObject(blockPaths)
//      newRevision.setAttachmentNamed("blockPaths", withContentType: "UIBezierPath", content: blockPathsData)
//      assert(newRevision.save(&error) != nil)
//      
//      documentID = document.documentID
//    } else {
//      assert(schemeID != nil, "ERROR! SchemeID is missing")
//    }
//  }
  
  
  func buildLibraryQuiltImage(quiltSize:CGSize, scheme:Scheme, showPaths:Bool) -> UIImage {
    
    let blockWidth = quiltSize.width / CGFloat(blocksAcross)
    let blockSize = CGSize(width: blockWidth, height: blockWidth)
    
    var quiltBlocks:[QuiltBlock] = []
    
    let query = database.viewNamed("quiltBlocks").createQuery()
    query.startKey = self.documentID
    query.endKey = self.documentID
    var error:NSError?
    let result = query.run(&error)
    while let row = result?.nextRow() {
      let quiltBlock = QuiltBlock()
      quiltBlock.load(row.documentID)
      quiltBlock.image = quiltBlock.block?.buildLibraryQuiltBlockImage(blockSize, scheme: scheme, showPaths: showPaths)
      
      quiltBlocks.append(quiltBlock)
    }
    println("buildLibraryQuiltImage - loaded \(quiltBlocks.count) blocks")
    
    
    UIGraphicsBeginImageContextWithOptions(quiltSize, true, 0.0)
    let context = UIGraphicsGetCurrentContext()
    UIColor.whiteColor().setFill()
    CGContextFillRect(context, CGRect(origin: CGPointZero, size: blockSize))
    
    
    var blockRect = CGRect(origin: CGPointZero, size: blockSize)
    
    cellVisitor {
      (location: QuiltMatrix) in
      let blockID = self[location]
      for quiltBlock in quiltBlocks {
        if quiltBlock.documentID == blockID {
          blockRect.origin.x = CGFloat(location.column) * blockWidth
          blockRect.origin.y = CGFloat(location.row) * blockWidth
          quiltBlock.image?.drawInRect(blockRect)
          break
        }
      }
      
    }
//    for row in 0..<self.blocksDown {
//      for column in 0..<self.blocksAcross {
//        let blockID = self[row, column]
//        for quiltBlock in quiltBlocks {
//          if quiltBlock.documentID == blockID {
//            blockRect.origin.x = CGFloat(column) * blockWidth
//            blockRect.origin.y = CGFloat(row) * blockWidth
//            quiltBlock.image?.drawInRect(blockRect)
//            break
//          }
//        }
//      }
//    }
    var image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
  }
  
  
  func buildUserQuiltImage(size:CGSize) -> UIImage {
    
    let blockSize = size.width / CGFloat(blocksAcross)
    
    var quiltBlocks:[QuiltBlock] = []
    
    let query = database.viewNamed("quiltBlocks").createQuery()
    query.startKey = self.documentID
    query.endKey = self.documentID
    var error:NSError?
    let result = query.run(&error)
    while let row = result?.nextRow() {
      let quiltBlock = QuiltBlock()
      quiltBlock.load(row.documentID)
      quiltBlocks.append(quiltBlock)
      
    }
    println("buildUserQuiltImage - loaded \(quiltBlocks.count) blocks")
    
    
    UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
    let context = UIGraphicsGetCurrentContext()
    UIColor.whiteColor().setFill()
    CGContextFillRect(context, CGRect(origin: CGPointZero, size: size))
    
    var blockRect = CGRect(origin: CGPointZero, size: CGSize(width: blockSize, height: blockSize))
    
    cellVisitor {
      (location: QuiltMatrix) in
      let blockID = self[location]
      for quiltBlock in quiltBlocks {
        if quiltBlock.documentID == blockID {
          blockRect.origin.x = CGFloat(location.column) * blockSize
          blockRect.origin.y = CGFloat(location.row) * blockSize
          quiltBlock.image?.drawInRect(blockRect)
          break
        }
      }
    }
//    for row in 0..<self.blocksDown {
//      for column in 0..<self.blocksAcross {
//        let blockID = self[row, column]
//        for quiltBlock in quiltBlocks {
//          if quiltBlock.documentID == blockID {
//            blockRect.origin.x = CGFloat(column) * blockSize
//            blockRect.origin.y = CGFloat(row) * blockSize
//            quiltBlock.image?.drawInRect(blockRect)
//            break
//          }
//        }
//      }
//    }
    var image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
  }
}

extension Quilt: DatabaseProtocol {
  func save() {
    if let schemeID = schemeID {
      println("saving Quilt")
      let properties = ["type": "Quilt",
        "name": name,
        "blocksAcross": blocksAcross,
        "blocksDown": blocksDown,
        "library":library,
        "schemeID":schemeID,
        //        "quiltBlocksID": quiltBlocksID,
        "blocks": blocks
      ]
      let document = gSave(properties)
      var error:NSError?

      var newRevision = document.currentRevision.createRevision()
      let imageData = UIImagePNGRepresentation(image)
      newRevision.setAttachmentNamed("image.png", withContentType: "image/png", content: imageData)
      assert(newRevision.save(&error) != nil)
      
      documentID = document.documentID
    } else {
      assert(schemeID != nil, "ERROR! SchemeID is missing")
    }
    
  }
  
  func load(documentID:String) {
    println("Loading Quilt: \(documentID)")
    self.documentID = documentID
    
    let document = database.documentWithID(documentID)
    if let name = document["name"] as? String {
      self.name = name
    }
    
    if let blocksAcross = document["blocksAcross"] as? Int {
      self.blocksAcross = blocksAcross
    }
    
    if let blocksDown = document["blocksDown"] as? Int {
      self.blocksDown = blocksDown
    }
    
    if let library = document["library"] as? Bool {
      self.library = library
    }
    
    //    if let quiltBlocksID = document["quiltBlocksID"] as? [[String]] {
    //      self.quiltBlocksID = quiltBlocksID
    //    }
    
    if let blocks = document["blocks"] as? [String] {
      self.blocks = blocks
    }
    if let schemeID = document["schemeID"] as? String {
      self.schemeID = schemeID
    } else {
      assert(schemeID != nil, "ERROR! SchemeID is missing")
    }
    
    let revision = document.currentRevision
    if let imageData = revision.attachmentNamed("image.png") {
      if let image = UIImage(data: imageData.content, scale: UIScreen.mainScreen().scale) {
        self.image = image
      }
    }
  }
  
  func update(documentID:String) {
    println("updating Quilt: \(documentID)")
    var error:NSError?
    let document = database.documentWithID(documentID)
    let properties = NSMutableDictionary(dictionary: document.properties)
    
    properties["type"] = "Quilt"
    properties["name"] = name
    properties["blocksAcross"] = blocksAcross
    properties["blocksDown"] = blocksDown
    properties["library"] = library
    //    properties["quiltBlocksID"] = quiltBlocksID
    properties["blocks"] = self.blocks
    properties["schemeID"] = schemeID
    
    if document.putProperties(properties as [NSObject : AnyObject], error: &error) == nil {
      println("couldn't save new item \(error?.localizedDescription)")
    }
    
    var newRevision = document.currentRevision.createRevision()
    let imageData = UIImagePNGRepresentation(image)
    newRevision.setAttachmentNamed("image.png", withContentType: "image/png", content: imageData)
    assert(newRevision.save(&error) != nil)
    
  }

}
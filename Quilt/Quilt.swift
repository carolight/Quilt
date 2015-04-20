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
  
  var borderWidth:CGFloat = 0
  var sashingWidth: CGFloat = 0
  
  //Scheme
  var schemeID:String? = nil
  var _scheme:Scheme? = nil
  var scheme:Scheme? {
    get {
      if let schemeID = self.schemeID {
        if _scheme == nil {
          _scheme = Scheme()
          _scheme!.load(schemeID)
        }
      } else {
        return nil
      }
      return _scheme!
    }
    set {
      _scheme = newValue
      schemeID = newValue?.documentID
    }
  }

  init() {
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
    //clears all block pointers
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
    newQuilt.scheme = scheme
    newQuilt.blocksAcross = self.blocksAcross
    newQuilt.blocksDown = self.blocksDown
    newQuilt.borderWidth = self.borderWidth
    newQuilt.sashingWidth = self.sashingWidth
    newQuilt.blocks = self.blocks
//    //need to save to get document id to save in user blocks
//    newQuilt.save()
//    //copy quilt blocks to user blocks
//    let query = database.viewNamed("quiltBlocks").createQuery()
//    query.startKey = self.documentID
//    query.endKey = self.documentID
//    
//    var error:NSError?
//    let result = query.run(&error)
//    while let row = result?.nextRow() {
//      let block = Block()
//      block.load(row.documentID)
//      let newBlock = block.copy()
//      newBlock.quiltID = newQuilt.documentID
//      newBlock.save()
//      
//      //update quilt matrix to point at new block
//      cellVisitor {
//        if self[$0] == block.documentID {
//          newQuilt[$0] = newBlock.documentID!
//        }
//      }
//      //TODO: This also copies blocks that may be redundant ie not used in quilt
//    }
    
    //newQuilt is updated with other details on return
    return newQuilt
  }
  
  func buildLibraryQuiltImage(quiltSize:CGSize, scheme:Scheme?, showPaths:Bool) -> UIImage {
    
    let blockWidth = quiltSize.width / CGFloat(blocksAcross)
    let blockSize = CGSize(width: blockWidth, height: blockWidth)
    
    var blockIDs = Set<String>()

    cellVisitor {
      blockIDs.insert(self[$0])
    }
    
    var blocks:[Block] = []
    for blockID in blockIDs {
      let block = Block()
      block.load(blockID)
      if block.library {
        block.image = block.buildLibraryQuiltBlockImage(blockSize, scheme: scheme!, showPaths: showPaths)
      } else {
        block.image = block.buildUserQuiltBlockImage(blockSize, showPaths: false)
      }
      blocks.append(block)
    }
    println("buildLibraryQuiltImage - loaded \(blocks.count) blocks")
    
    UIGraphicsBeginImageContextWithOptions(quiltSize, true, 0.0)
    let context = UIGraphicsGetCurrentContext()
    UIColor.whiteColor().setFill()
    CGContextFillRect(context, CGRect(origin: CGPointZero, size: blockSize))

    var blockRect = CGRect(origin: CGPointZero, size: blockSize)
    
    cellVisitor {
      (location: QuiltMatrix) in
      let currentBlockID = self[location]
      for block in blocks {
        if currentBlockID == block.documentID {
          blockRect.origin.x = CGFloat(location.column) * blockWidth
          blockRect.origin.y = CGFloat(location.row) * blockWidth
          block.image?.drawInRect(blockRect)
          break
        }
      }
    }
    
    var image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
  }
  
  
//  func buildUserQuiltImage(size:CGSize) -> UIImage {
//    
//    let blockSize = size.width / CGFloat(blocksAcross)
//    
//    var quiltBlocks:[Block] = []
//    
//    let query = database.viewNamed("quiltBlocks").createQuery()
//    query.startKey = self.documentID
//    query.endKey = self.documentID
//    var error:NSError?
//    let result = query.run(&error)
//    while let row = result?.nextRow() {
//      let quiltBlock = Block()
//      quiltBlock.load(row.documentID)
//      quiltBlocks.append(quiltBlock)
//      
//    }
//    println("buildUserQuiltImage - loaded \(quiltBlocks.count) blocks")
//    
//    
//    UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
//    let context = UIGraphicsGetCurrentContext()
//    UIColor.whiteColor().setFill()
//    CGContextFillRect(context, CGRect(origin: CGPointZero, size: size))
//    
//    var blockRect = CGRect(origin: CGPointZero, size: CGSize(width: blockSize, height: blockSize))
//    
//    cellVisitor {
//      (location: QuiltMatrix) in
//      let blockID = self[location]
//      for quiltBlock in quiltBlocks {
//        if quiltBlock.documentID == blockID {
//          blockRect.origin.x = CGFloat(location.column) * blockSize
//          blockRect.origin.y = CGFloat(location.row) * blockSize
//          quiltBlock.image?.drawInRect(blockRect)
//          break
//        }
//      }
//    }
//    var image = UIGraphicsGetImageFromCurrentImageContext()
//    UIGraphicsEndImageContext()
//    return image
//  }
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
        "blocks": blocks,
        "borderWidth": borderWidth,
        "sashingWidth": sashingWidth
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
    
    if let blocks = document["blocks"] as? [String] {
      self.blocks = blocks
    }
    if let schemeID = document["schemeID"] as? String {
      self.schemeID = schemeID
    } else {
      assert(schemeID != nil, "ERROR! SchemeID is missing")
    }
    
    if let borderWidth = document["borderWidth"] as? CGFloat {
      self.borderWidth = borderWidth
    }
    if let sashingWidth = document["sashingWidth"] as? CGFloat {
      self.sashingWidth = sashingWidth
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
    properties["blocks"] = self.blocks
    properties["schemeID"] = schemeID
    properties["borderWidth"] = borderWidth
    properties["sashingWidth"] = sashingWidth
    
    if document.putProperties(properties as [NSObject : AnyObject], error: &error) == nil {
      println("couldn't save new item \(error?.localizedDescription)")
    }
    
    var newRevision = document.currentRevision.createRevision()
    let imageData = UIImagePNGRepresentation(image)
    newRevision.setAttachmentNamed("image.png", withContentType: "image/png", content: imageData)
    assert(newRevision.save(&error) != nil)
    
  }

}
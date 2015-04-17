//
//  LoadViewController.swift
//  Quilt
//
//  Created by Caroline Begbie on 8/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import UIKit

class LoadViewController: UIViewController {

  var defaultSchemeID:String!
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      deleteDatabase()
      
      setupColorSchemes()
      loadBlocks()
      setupQuilts()

    }


  func loadBlocks() {
    var blocksPath = NSBundle.mainBundle().resourcePath!
    blocksPath = blocksPath.stringByAppendingString("/blocks/")
    let manager = NSFileManager.defaultManager()
    let directoryEnum = manager.enumeratorAtPath(blocksPath)
    while let file = directoryEnum?.nextObject() as? String {
      let filename = blocksPath.stringByAppendingString(file)
      println("loading: \(filename)")
      if let dictionary = NSDictionary(contentsOfFile: filename) {
        let block = Block()
        block.loadFromDictionary(dictionary)
        block.save()
      }
    }
    println("Blocks are loaded")
  }
  
  func setupQuilts() {
    var quiltSize = CGSize(width:240, height:400)
    var blockSize = CGSize(width: 40, height: 40)
    var blocksAcross = 5
    var blocksDown = 9
    var borderWidth:CGFloat = 20
    
    blockSize.width = (quiltSize.width - borderWidth*2) / CGFloat(blocksAcross)
    blockSize.height = blockSize.width
    
    var quilt = Quilt()
    quilt.blocksAcross = blocksAcross
    quilt.blocksDown = blocksDown
    
    var rect = CGRect(origin: CGPointZero, size: quiltSize)
    
    quilt.name = "untitled 1"
    quilt.blockSize = blockSize
    quilt.library = true
    quilt.schemeID = defaultSchemeID
    
    UIGraphicsBeginImageContextWithOptions(quiltSize, true, 0)
    let context = UIGraphicsGetCurrentContext()
    UIColor.whiteColor().setFill()
    UIColor.blackColor().setStroke()
    
    //  top border
    var path = UIBezierPath(rect: rect)
    path.fill()
    rect.size.height = borderWidth
    path = UIBezierPath(rect: rect)
    path.stroke()
    
    //  bottom border
    rect.origin.y = quiltSize.height - borderWidth
    path = UIBezierPath(rect: rect)
    path.stroke()
    
    
    //  left border
    rect.origin.y = borderWidth
    rect.size.width = borderWidth
    rect.size.height = quiltSize.height - borderWidth*2
    path = UIBezierPath(rect: rect)
    path.stroke()
    
    //  right border
    rect.origin.x = quiltSize.width - borderWidth
    path = UIBezierPath(rect: rect)
    path.stroke()
    
    rect.size = blockSize
    for column in 0..<blocksAcross {
      for row in 0..<blocksDown {
        rect.origin.x = CGFloat(column) * blockSize.width + borderWidth
        rect.origin.y = CGFloat(row) * blockSize.height + borderWidth
        path = UIBezierPath(rect: rect)
        UIColor.yellowColor().setFill()
        //      path.stroke()
        path.fill()
        quilt.blockPaths.append(path)
        
      }
    }
    
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    quilt.image = image
    quilts.append(quilt)
    quilt.save()
    
    
    // setup new quilt blocks
    
    //find a block to save into the quilt
    let query = database.viewNamed("blocks").createQuery()
    var error:NSError?
    let result = query.run(&error)
    var block = Block()
    while let row = result?.nextRow() {
      let documentID = row.documentID
      block.load(documentID)
      println("found block: \(block.name)")
      break
    }
    
    println("result count: \(result.count)")
    
    let quiltBlock = QuiltBlock()
    quiltBlock.quiltID = quilt.documentID
    quiltBlock.blockID = block.documentID
    quiltBlock.image = block.image
    quiltBlock.save()
    
    //update quilt matrix to point at new block
    for row in 0..<blocksDown {
      for column in 0..<blocksAcross {
        quilt.quiltBlocksID[row][column] = quiltBlock.documentID!
      }
    }
    quilt.update(quilt.documentID!)
  }
  
  
  func setupColorSchemes() {
    let colorScheme = Scheme()
    colorScheme.name = "Good Karma"
    colorScheme.fabrics = []
    colorScheme.fabrics.append("jpg_good-karma/7216-11.jpg")
    colorScheme.fabrics.append("jpg_good-karma/7216-12.jpg")
    colorScheme.fabrics.append("jpg_good-karma/7216-13.jpg")
    colorScheme.fabrics.append("jpg_good-karma/7216-14.jpg")
    colorScheme.fabrics.append("jpg_good-karma/7216-15.jpg")
    colorScheme.fabrics.append("jpg_good-karma/7216-16.jpg")
    
    colorScheme.loadFabricImages()
    colorScheme.save()
    defaultSchemeID = colorScheme.documentID
    
    colorScheme.name = "Farmhouse"
    colorScheme.fabrics = []
    colorScheme.fabrics.append("jpg_farmhouse/20199-74.jpg")
    colorScheme.fabrics.append("jpg_de-la-sol-batiks/4337-16.jpg")
    colorScheme.fabrics.append("jpg_farmhouse/20250-13.jpg")
    colorScheme.fabrics.append("jpg_farmhouse/20250-14.jpg")
    colorScheme.fabrics.append("jpg_farmhouse/20250-15.jpg")
    colorScheme.fabrics.append("jpg_farmhouse/20250-17.jpg")
    
    colorScheme.loadFabricImages()
    colorScheme.save()
    
    colorScheme.name = "Farmhouse2"
    colorScheme.fabrics = []
    colorScheme.fabrics.append("jpg_farmhouse/20251-18.jpg")
    colorScheme.fabrics.append("jpg_farmhouse/20252-14.jpg")
    colorScheme.fabrics.append("jpg_farmhouse/20253-11.jpg")
    colorScheme.fabrics.append("jpg_farmhouse/20254-14.jpg")
    colorScheme.fabrics.append("jpg_farmhouse/20255-18.jpg")
    colorScheme.fabrics.append("jpg_farmhouse/20256-18.jpg")
    
    colorScheme.loadFabricImages()
    colorScheme.save()
    
    
  }

  
  func deleteDatabase() {
    println(" ")
    println("----")
    println("Database name: \(database.name)")
    println("----")
    println(" ")

    let name = database.name

    var error: NSError?
    if !database.deleteDatabase(&error) {
      println("Can't delete database. Error: \(error?.localizedDescription)")
    }
    database = nil

    println("Deleted Database")
    
    
    createDB(name)
    createViews()
  }
}

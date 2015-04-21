//
//  BlockSelectViewController.swift
//  Quilt
//
//  Created by Caroline Begbie on 17/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import UIKit

class BlockSelectViewController: UIViewController {

  var currentQuilt:Quilt!
  var currentBlock:Block!
  var quiltMatrixID:Int = 0
  
  var collectionViewController:CollectionViewController!
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      collectionViewController.array = []
      collectionViewController.array.append(currentBlock)
      collectionViewController.appState = .Block
      
      self.title = currentBlock.name
      
      
      //User blocks and library blocks will all be loaded
      //and generic blocks will be created
      //these should not be saved! If a user block (QuiltBlock)
      //is saved as a library block (Block)
      //it is disaster
      //TODO: sort out quilt/block
      
      let query = database.viewNamed("blocks").createQuery()
      var error:NSError?
      let result = query.run(&error)
      while let row = result?.nextRow() {
        if let library = row.document["library"] as? Bool {
          println(library)
        } else {
          println("not found")
        }
        let block = Block()
        if row.documentID != currentBlock.documentID {
          block.load(row.documentID)
          collectionViewController.array.append(block)
        }
      }
      
      println("blocks loaded: \(collectionViewController.array.count)")
      

    }

  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    println(segue.identifier)
    if segue.identifier == "BlockCollectionViewController" {
      if let collectionViewController = segue.destinationViewController as? CollectionViewController {
        self.collectionViewController = collectionViewController
        collectionViewController.delegate = self
        collectionViewController.appState = .Quilt
      }
    }
  }

}

extension BlockSelectViewController: CollectionViewControllerDelegate {
  func didSelectItem(item: AnyObject) {
    if let block = item as? Block {
      let navigationController = storyboard?.instantiateViewControllerWithIdentifier("BlockNavigationController") as! UINavigationController
      let blockViewController = navigationController.viewControllers[0] as! BlockViewController
      
//      let quiltBlock = Block()
//      if block.library {
//        //TODO: copy block to quiltBlock
//        quiltBlock.documentID = nil
//        quiltBlock.name = block.name
//        quiltBlock.quiltID = currentQuilt.documentID
//        quiltBlock.library = false
//        quiltBlock.image = quiltBlock.buildUserQuiltBlockImage(CGSize(width: 100, height: 100), showPaths: false)
//
//      } else {
//        quiltBlock.load(block.documentID!)
//      }
//      blockViewController.block = quiltBlock
      blockViewController.block = block
      blockViewController.title = block.name
      presentViewController(navigationController, animated: true, completion: nil)
    }
  }
  
  func didScrollToItem(item: AnyObject) {
    if let block = item as? Block {
      println("did scroll to \(block.name)")
      self.title = block.name
    }
  }
  
  func didBeginDragging() {
    self.title = " "
  }
}

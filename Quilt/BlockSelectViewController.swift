//
//  BlockSelectViewController.swift
//  Quilt
//
//  Created by Caroline Begbie on 17/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import UIKit

class BlockSelectViewController: UIViewController {

  var collectionViewController:CollectionViewController!
  
    override func viewDidLoad() {
        super.viewDidLoad()
      collectionViewController.appState = .Block
      
      blocks = []
      
      let query = database.viewNamed("blocks").createQuery()
      var error:NSError?
      let result = query.run(&error)
      while let row = result?.nextRow() {
        let block = Block()
        block.load(row.documentID)
        collectionViewController.array.append(block)
      }
      

    }

  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    println(segue.identifier)
    if segue.identifier == "BlockCollectionViewController" {
      if let collectionViewController = segue.destinationViewController as? CollectionViewController {
        self.collectionViewController = collectionViewController
        collectionViewController.appState = .Quilt
      }
    }
  }

}

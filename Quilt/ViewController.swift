//
//  ViewController.swift
//  Quilt
//
//  Created by Caroline Begbie on 1/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Select Quilt"
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    println(segue.identifier)
    if segue.identifier == "QuiltCollectionViewController" {
      if let collectionViewController = segue.destinationViewController as? CollectionViewController {
        collectionViewController.appState = .Quilt
        
        let query = database.viewNamed("quilts").createQuery()
        var error:NSError?
        let result = query.run(&error)
        while let row = result?.nextRow() {
          let quilt = Quilt()
          quilt.load(row.documentID)
          collectionViewController.array.append(quilt)
        }
      }
    }
  }
}

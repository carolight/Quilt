//
//  LoadViewController.swift
//  Quilt
//
//  Created by Caroline Begbie on 8/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import UIKit

class LoadViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
      
      setupQuilts()
      loadBlocks()

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
    println("done")
  }
}

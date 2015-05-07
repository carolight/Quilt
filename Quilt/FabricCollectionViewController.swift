//
//  FabricCollectionViewController.swift
//  Quilt
//
//  Created by Caroline Begbie on 4/05/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import UIKit

protocol FabricCollectionViewControllerDelegate {
  func didSelectFabric(fabric: Fabric)
}

class FabricCollectionViewController: UICollectionViewController {

  var array:[Fabric] = []
  var delegate:FabricCollectionViewControllerDelegate? = nil
  
    override func viewDidLoad() {
        super.viewDidLoad()

      var fabricsPath = NSBundle.mainBundle().resourcePath!
      fabricsPath = fabricsPath.stringByAppendingString("/fabrics/")
      let manager = NSFileManager.defaultManager()
      let directoryEnum = manager.enumeratorAtPath(fabricsPath)
      while let file = directoryEnum?.nextObject() as? String {
        let filename = fabricsPath.stringByAppendingString(file)
        if let image = UIImage(contentsOfFile: filename) {
          let fabric = Fabric()
          fabric.name = file
          fabric.image = image
          array.append(fabric)
        }
      }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array.count
    }

  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FabricCollectionCell", forIndexPath: indexPath) as! UICollectionViewCell
    if let imageView = cell.contentView.viewWithTag(1) as? UIImageView {
      let fabric = array[indexPath.row]
      imageView.image = fabric.image!
    }
    return cell
  }

  // MARK: UICollectionViewDelegate

  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let fabric = array[indexPath.row]
    println("selected: \(fabric.name)")
    delegate?.didSelectFabric(fabric)
  }



}

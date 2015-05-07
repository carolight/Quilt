//
//  BlockCollectionViewController.swift
//  Quilt
//
//  Created by Caroline Begbie on 7/05/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import UIKit

protocol BlockCollectionViewControllerDelegate {
  func didSelectBlock(block: Block)
}


class BlockCollectionViewController: UICollectionViewController {

  var array:[Block] = []
  var delegate:BlockCollectionViewControllerDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

      let query = database.viewNamed("blocks").createQuery()
      var error:NSError?
      let result = query.run(&error)
      while let row = result?.nextRow() {
        let block = Block()
        block.load(row.documentID)
        array.append(block)
      }

    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BlockCollectionCell", forIndexPath: indexPath) as! UICollectionViewCell
      if let imageView = cell.contentView.viewWithTag(1) as? UIImageView {
        let block = array[indexPath.row]
        imageView.image = block.image!
      }
      return cell
    }

    // MARK: UICollectionViewDelegate

  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let block = array[indexPath.row]
    println("selected: \(block.name)")
    delegate?.didSelectBlock(block)
  }

}

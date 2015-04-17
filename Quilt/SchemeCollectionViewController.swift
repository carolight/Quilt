//
//  SchemeCollectionViewController.swift
//  Quilt
//
//  Created by Caroline Begbie on 11/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import UIKit

protocol SchemeCollectionViewControllerDelegate {
  func didSelectColorScheme(scheme:Scheme)
}

class SchemeCollectionViewController: UICollectionViewController {
  
  var colors:[UIColor] = []
  var schemes:[Scheme] = []
  var delegate: SchemeCollectionViewControllerDelegate? = nil
  var selectedScheme = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.automaticallyAdjustsScrollViewInsets = false
    
    colors.append(UIColor.blueColor())
    colors.append(UIColor.orangeColor())
    colors.append(UIColor.redColor())
    colors.append(UIColor.greenColor())
    colors.append(UIColor.grayColor())
    colors.append(UIColor.purpleColor())
    
    let query = database.viewNamed("schemes").createQuery()
    var error:NSError?
    let result = query.run(&error)
    while let row = result?.nextRow() {
      let scheme = Scheme()
      println("loading scheme in viewDidLoad")
      scheme.load(row.documentID)
      schemes.append(scheme)
    }

  }
  
  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return schemes.count
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SchemeCollectionViewCell", forIndexPath: indexPath) as! CollectionViewCell
    
    let scheme = schemes[indexPath.row]
    
    
    cell.contentView.backgroundColor = colors[indexPath.row]
    cell.imageView.image = scheme.image
    
    if indexPath.row == selectedScheme {
      cell.contentView.layer.borderColor = UIColor.redColor().CGColor
      cell.contentView.layer.borderWidth = 2.0
    } else {
      cell.contentView.layer.borderColor = UIColor.blackColor().CGColor
      cell.contentView.layer.borderWidth = 1.0
    }
    return cell
  }
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let scheme = schemes[indexPath.row]
    selectedScheme = indexPath.row
    collectionView.reloadData()
    delegate?.didSelectColorScheme(scheme)
    
  }
  
  
}

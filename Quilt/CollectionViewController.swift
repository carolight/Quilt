//
//  CollectionViewController.swift
//  Quilt
//
//  Created by Caroline Begbie on 3/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import UIKit

protocol CollectionViewControllerDelegate {
  func didSelectItem(item:AnyObject)
}

enum AppState {
  case Quilt, Block, Fabric
}

let reuseIdentifier = "CollectionViewCell"

class CollectionViewController: UICollectionViewController {

  var array:[AnyObject] = []
  var delegate:CollectionViewControllerDelegate? = nil
  var appState:AppState = .Quilt
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      switch appState {
      case .Quilt:
        self.title = "Select Quilt"
      case .Block:
        self.title = "Select Block"
      case .Fabric:
        self.title = "Select Fabric"
      }
      let flowLayout = CollectionViewFlowLayout()
      self.collectionView?.collectionViewLayout = flowLayout
      self.collectionView?.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

  
}

extension CollectionViewController: UICollectionViewDataSource {
  
  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return array.count
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    var image:UIImage
    switch appState {
    case .Quilt:
      let quilt = array[indexPath.row] as Quilt
      image = quilt.image!
    default:
      image = array[indexPath.row] as UIImage
    }
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as CollectionViewCell
    cell.imageView.image = image
    
    return cell
    
  }
}

extension CollectionViewController: UICollectionViewDelegate {
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    switch appState {
    case .Quilt:
      let quiltViewController = storyboard?.instantiateViewControllerWithIdentifier("QuiltViewController") as QuiltViewController
//      let quilt = array[indexPath.row] as UIImage
      let quilt = array[indexPath.row] as Quilt
      quiltViewController.quilt = quilt
      navigationController?.pushViewController(quiltViewController, animated: true)
    case .Block:
      let blockViewController = storyboard?.instantiateViewControllerWithIdentifier("BlockViewController") as BlockViewController
      blockViewController.title = "Block"
      let blockimage = array[indexPath.row] as UIImage
      blockViewController.image = blockimage
      
      if indexPath.row < blocks.count {
        let block = blocks[indexPath.row]
        println("selected block: \(block.name)")
        blockViewController.block = block
      }

    
      var viewControllers = navigationController?.viewControllers
      viewControllers?.removeLast()
      viewControllers?.append(blockViewController)
      navigationController?.setViewControllers(viewControllers, animated: true)
      
//      navigationController?.pushViewController(blockViewController, animated: true)
    case .Fabric:
      
      let image = array[indexPath.row] as UIImage 
      delegate?.didSelectItem(image)
      
      navigationController?.popViewControllerAnimated(true)
      
    }
  }
}


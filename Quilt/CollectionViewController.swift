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
  
  var selectedScheme:Scheme? = nil
  
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

//    println("Height: \(flowLayout.itemSize.height)")
//    if let collectionView = self.collectionView {
//      flowLayout.itemSize.width = collectionView.bounds.width
//      flowLayout.itemSize.height = collectionView.bounds.height + 20
//    }
//    println("Height: \(flowLayout.itemSize.height)")
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
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CollectionViewCell
    
    var image:UIImage? = nil
    switch appState {
    case .Quilt:
      if let quilt = array[indexPath.row] as? Quilt {
        if quilt.library {
          var scheme = selectedScheme
          
          if scheme == nil {
            //get first color scheme
            let query = database.viewNamed("schemes").createQuery()
            var error:NSError?
            let result = query.run(&error)
            scheme = Scheme()
            while let row = result?.nextRow() {
              scheme!.load(row.documentID)
              break
            }
          }
          
          if let scheme = scheme {
            image = quilt.buildLibraryQuiltImage(cell.imageView.bounds.size, scheme: scheme)
          }
        } else {
          image = quilt.buildUserQuiltImage(cell.imageView.bounds.size)
        }
      }
    case .Block:
      if let block = array[indexPath.row] as? Block {
//        image = block.image
        
        //TODO: - should this be created or be stock block image?
        let size = min(cell.contentView.bounds.width, cell.contentView.bounds.height)
        image = block.createImage(CGSize(width: size, height: size))
      }
    default:
      if let fabric = array[indexPath.row] as? Fabric {
        image = fabric.image!
      }
    }
    if let image = image {
      cell.imageView.image = image
    }
    
    return cell
  }

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    
    //TODO: this shouldn't be here, but not sure where to set it
    self.collectionView?.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    return CGSizeMake(collectionView.bounds.size.width - 20 , collectionView.bounds.size.height - 20)
  
  }
}

extension CollectionViewController: UICollectionViewDelegate {
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    switch appState {
    case .Quilt:
      let quiltViewController = storyboard?.instantiateViewControllerWithIdentifier("QuiltViewController") as! QuiltViewController
      let quilt = array[indexPath.row] as! Quilt
      quiltViewController.quilt = quilt
      
      //TODO: - selectedScheme is not being updated initially
      if selectedScheme == nil {
        //get first color scheme
        let query = database.viewNamed("schemes").createQuery()
        var error:NSError?
        let result = query.run(&error)
        selectedScheme = Scheme()
        while let row = result?.nextRow() {
          selectedScheme!.load(row.documentID)
          break
        }
      }

      quiltViewController.currentScheme = selectedScheme
      navigationController?.pushViewController(quiltViewController, animated: true)
    case .Block:
      
      let navigationController = storyboard?.instantiateViewControllerWithIdentifier("BlockNavigationController") as! UINavigationController
      let blockViewController = navigationController.viewControllers[0] as! BlockViewController
      blockViewController.title = "Block"
      let block = array[indexPath.row] as! Block
      
      blockViewController.block = block
      
      
      //TODO: instead of block, blockViewController should be showing UserBlock
      
      presentViewController(navigationController, animated: true, completion: nil)
    case .Fabric:
      
      let fabric = array[indexPath.row] as! Fabric
      delegate?.didSelectItem(fabric)
      
      navigationController?.popViewControllerAnimated(true)
      
    }
  }
  
  override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    //TODO: Change title and center
  }
}


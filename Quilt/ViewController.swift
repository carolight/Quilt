//
//  ViewController.swift
//  Quilt
//
//  Created by Caroline Begbie on 1/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  
  var array:[AnyObject] = []
  @IBOutlet weak var collectionView: UICollectionView!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "Select Quilt"
    let flowLayout = CollectionViewFlowLayout()
    self.collectionView.collectionViewLayout = flowLayout
    self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    println(segue.identifier)
    if segue.identifier == "QuiltCollectionViewController" {
      println(segue.destinationViewController)
      if let collectionViewController = segue.destinationViewController as? CollectionViewController {
        collectionViewController.appState = .Quilt
        println("HERE")
        println(quilts)
        
        for quilt in quilts {
          println(quilt.name)
          collectionViewController.array.append(quilt)
//          collectionViewController.array.append(quilt.image!)
        }
//        for i in 0..<5 {
//          println("quilt\(i).jpg")
//          if let image = UIImage(named: "quilt\(i).jpg") {
//            collectionViewController.array.append(image)
//          }
//        }

      }
    }
  }
}

extension ViewController: UICollectionViewDataSource {
  
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return array.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let quilt = array[indexPath.row] as Quilt
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as QuiltCollectionViewCell
    cell.imageView.image = quilt.image
    cell.tapGesture = UITapGestureRecognizer(target: cell, action: "handleTap:")
    cell.tapGesture.numberOfTapsRequired = 1
    
    cell.swipeGesture = UISwipeGestureRecognizer(target: cell, action: "handleSwipe:")
    cell.swipeGesture.direction = .Up | .Down
    
    cell.imageView.userInteractionEnabled = true
    cell.imageView.addGestureRecognizer(cell.swipeGesture)
    cell.setupOptionsView()

    return cell
    
  }
}

extension ViewController: UICollectionViewDelegate {
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let quiltViewController = storyboard?.instantiateViewControllerWithIdentifier("QuiltViewController") as QuiltViewController
    let quilt = array[indexPath.row] as Quilt
    quiltViewController.quilt = quilt
    navigationController?.pushViewController(quiltViewController, animated: true)
  }
}

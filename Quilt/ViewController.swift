//
//  ViewController.swift
//  Quilt
//
//  Created by Caroline Begbie on 1/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  
  var array:[UIImage] = []
  @IBOutlet weak var collectionView: UICollectionView!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    for i in 0..<5 {
      println("quilt\(i).jpg")
      if let image = UIImage(named: "quilt\(i).jpg") {
        array.append(image)
      }
    }
    
    println(array)

    let flowLayout = CollectionViewFlowLayout()
    self.collectionView.collectionViewLayout = flowLayout
    self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
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
    let quilt = array[indexPath.row]
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as QuiltCollectionViewCell
    cell.imageView.image = quilt
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
    let quilt = array[indexPath.row]
    quiltViewController.image = quilt
    navigationController?.pushViewController(quiltViewController, animated: true)
  }
}

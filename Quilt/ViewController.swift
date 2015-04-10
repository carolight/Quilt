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
  
  func printAll() {
    println("-- PRINTING ALL")
    database.viewNamed("all").setMapBlock("2") {
      (document, emit) in
      if let object:AnyObject = document["name"] {
        if let name = object as? String {
          emit(name, document)
        }
      }
    }
    let query = database.viewNamed("all").createQuery()
    var error:NSError?
    let result = query.run(&error)
    while let row = result?.nextRow() {
      println("\(row.key) / \(row.value)")
      println("Document: \(row.document)")
    }
    println("-- END ALL")
  }
  
  func useDatabase() {
    database.viewNamed("quiltName").setMapBlock("2") {
      (document, emit) in
      if document["type"] as? String == "Quilt" {
        if let object:AnyObject = document["name"] {
          if let name = object as? String {
            emit(name, document)
          }
        }
      }
    }
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    printAll()
    
    
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
        
        
        useDatabase()
        quilts = []
        
        let query = database.viewNamed("quiltName").createQuery()
        var error:NSError?
        let result = query.run(&error)
        while let row = result?.nextRow() {
          println("\(row.key) / \(row.value)")
          let quilt = Quilt()
          quilt.load(row.documentID)
          //          quilts.append(quilt)
          collectionViewController.array.append(quilt)
        }
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
    let quilt = array[indexPath.row] as! Quilt
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! QuiltCollectionViewCell
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
    let quiltViewController = storyboard?.instantiateViewControllerWithIdentifier("QuiltViewController") as! QuiltViewController
    let quilt = array[indexPath.row] as! Quilt
    quiltViewController.quilt = quilt
    navigationController?.pushViewController(quiltViewController, animated: true)
  }
}

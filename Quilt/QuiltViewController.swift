//
//  QuiltViewController.swift
//  Quilt
//
//  Created by Caroline Begbie on 1/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import UIKit

class QuiltViewController: UIViewController {
  
  var quilt:Quilt!
  
  var quiltBlocks:[QuiltBlock] = []
  
  @IBOutlet weak var scrollView: UIScrollView!
  
  
  @IBOutlet weak var quiltView: QuiltView!
  
//  func useDatabase() {
//    database.viewNamed("blockName").setMapBlock("2") {
//      (document, emit) in
//      if document["type"] as? String == "Block" {
//        if let object:AnyObject = document["name"] {
//          if let name = object as? String {
//            emit(name, document)
//          }
//        }
//      }
//    }
//  }
  
  func createNewQuilt() {
    let newQuilt = quilt.copy()
    newQuilt.name = "Mine"
    newQuilt.library = false
    //newQuilt has already been saved once
    newQuilt.update(newQuilt.documentID!)
    
    
    
    self.quilt = newQuilt

  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    createNewQuilt()
    
    quiltView.image = quilt.image
    quiltView.delegate = self
    quiltView.paths = quilt.blockPaths
    quiltView.blockSize = quilt.blockSize
    
    scrollView.delegate = self
    
    scrollView.contentSize = quiltView.bounds.size
    
    let scrollViewFrame = scrollView.frame
    let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
    let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
    let minScale = min(scaleWidth, scaleHeight);
    scrollView.minimumZoomScale = minScale;
    println("min: \(minScale)")
    println("Image: \(quilt.image?.size)")
    println(scrollView.bounds)
    // 5
    scrollView.maximumZoomScale = 2.0
    scrollView.zoomScale = minScale;
    
    self.automaticallyAdjustsScrollViewInsets = false
    
    createViews()
    
    println("here")
    //display blocks on quilt
    let query = database.viewNamed("quiltBlocks").createQuery()
    println(quilt.documentID)
    query.startKey = quilt.documentID
    query.endKey = quilt.documentID
    var error:NSError?
    let result = query.run(&error)
    while let row = result?.nextRow() {
      let quiltBlock = QuiltBlock()
      quiltBlock.load(row.documentID)
      let imageView = UIImageView(image: quiltBlock.image)
      let x = quiltBlock.column * 100
      let y = quiltBlock.row * 100
      let frame = CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: 100, height: 100))
      imageView.frame = frame
      quiltView.addSubview(imageView)
    }
    println(query)
    println("query done")

  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func scrollViewDoubleTapped(recognizer: UITapGestureRecognizer) {
    println("double tap")
    // 1
    let pointInView = recognizer.locationInView(quiltView)
    
    // 2
    var newZoomScale = scrollView.zoomScale * 1.5
    newZoomScale = min(newZoomScale, scrollView.maximumZoomScale)
    
    // 3
    let scrollViewSize = scrollView.bounds.size
    let w = scrollViewSize.width / newZoomScale
    let h = scrollViewSize.height / newZoomScale
    let x = pointInView.x - (w / 2.0)
    let y = pointInView.y - (h / 2.0)
    
    let rectToZoomTo = CGRectMake(x, y, w, h);
    
    // 4
    scrollView.zoomToRect(rectToZoomTo, animated: true)
  }
  
  func centerScrollViewContents() {
    let boundsSize = scrollView.bounds.size
    var contentsFrame = quiltView.frame
    
    if contentsFrame.size.width < boundsSize.width {
      contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
    } else {
      contentsFrame.origin.x = 0.0
    }
    
    if contentsFrame.size.height < boundsSize.height {
      contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
    } else {
      contentsFrame.origin.y = 0.0
    }
    
    quiltView.frame = contentsFrame
  }
  
}

extension QuiltViewController: UIScrollViewDelegate {
  func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
    return quiltView
  }

  func scrollViewDidZoom(scrollView: UIScrollView) {
    centerScrollViewContents()
  }
}

extension QuiltViewController: QuiltViewDelegate {
  func quiltViewShouldShowBlock(quiltView: QuiltView, location:CGPoint) {
    if let collectionViewController = storyboard?.instantiateViewControllerWithIdentifier("CollectionViewController") as? CollectionViewController {
      collectionViewController.appState = .Block
      
      blocks = []
      
      let query = database.viewNamed("blocks").createQuery()
      var error:NSError?
      let result = query.run(&error)
      while let row = result?.nextRow() {
        println("\(row.key) / \(row.value)")
        let block = Block()
        block.load(row.documentID)
        collectionViewController.array.append(block)
      }
      
      navigationController?.pushViewController(collectionViewController, animated: true)
      
    }
  }
  
  func getBlockImage(location:CGPoint) -> UIImage? {
    let blockSize = CGSize(width: 100, height: 100)
    let rect = CGRect(origin: location, size: blockSize)
    
    UIGraphicsBeginImageContextWithOptions(quiltView.bounds.size, true, 1)
    let context = UIGraphicsGetCurrentContext()
    self.quilt.image!.drawInRect(quiltView.bounds)
    let quiltImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    let imageRef = CGImageCreateWithImageInRect(quiltImage.CGImage, rect)
    let image = UIImage(CGImage: imageRef)
    return image
    
  }
  
  @IBAction func exitBlockCancel(segue:UIStoryboardSegue) {
    println("cancel")
  }
  
  @IBAction func exitBlockSave(segue:UIStoryboardSegue) {
    println("save")
    println(segue.sourceViewController)
    
  }
  
}


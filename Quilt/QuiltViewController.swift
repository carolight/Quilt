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
  var currentScheme:Scheme!
  
  @IBOutlet weak var scrollView: UIScrollView!
  
  
  @IBOutlet weak var quiltView: QuiltView!
  
  func createNewQuilt() {
    let newQuilt = quilt.copy(currentScheme)
    newQuilt.name = "Mine"
    newQuilt.library = false
    newQuilt.schemeID = currentScheme.documentID
    
    //newQuilt has already been saved once
    newQuilt.update(newQuilt.documentID!)
    self.quilt = newQuilt
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if self.quilt.library {
      createNewQuilt()
    }
    
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
    // 5
    scrollView.maximumZoomScale = 2.0
    scrollView.zoomScale = minScale;
    
    self.automaticallyAdjustsScrollViewInsets = false
    
    //show blocks from quilt matrix
    for row in 0..<quilt.blocksDown {
      for column in 0..<quilt.blocksAcross {
        let quiltBlock = QuiltBlock()
        quiltBlock.load(quilt.quiltBlocksID[row][column])
        let imageView = UIImageView(image: quiltBlock.image)
        let x = column * 100
        let y = row * 100
        let frame = CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: 100, height: 100))
        imageView.frame = frame
        quiltView.addSubview(imageView)
        
        imageView.layer.borderColor = UIColor.blackColor().CGColor
        imageView.layer.borderWidth = 3
      }
    }
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
    if let collectionViewController = storyboard?.instantiateViewControllerWithIdentifier("BlockSelectViewController") as? BlockSelectViewController {
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
  }
  
}


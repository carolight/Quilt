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
  
  var currentQuiltMatrixID:Int = 0 // This is the entry into the quiltMatrix
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var quiltView: UIView!
  @IBOutlet weak var switchBlocks: UISwitch!
  
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
    
    let scheme = Scheme()
    scheme.load(quilt.schemeID!)
    gSelectedScheme = scheme
    
    if self.quilt.library {
      createNewQuilt()
    }
    
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
    
    quilt.cellVisitor {
      (location:QuiltMatrix) in
      let quiltBlock = QuiltBlock()
      quiltBlock.load(self.quilt[location])
      let imageView = UIImageView(image: quiltBlock.image)
      let x = location.column * 100
      let y = location.row * 100
      let frame = CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: 100, height: 100))
      imageView.frame = frame
      self.quiltView.addSubview(imageView)
      
      imageView.layer.borderColor = UIColor.blackColor().CGColor
      imageView.layer.borderWidth = 3
      
      //add matrix entry point
      imageView.tag = location.row * 1000 + location.column
      
      let tap = UITapGestureRecognizer(target: self, action: "handleBlockTap:")
      imageView.addGestureRecognizer(tap)
      imageView.userInteractionEnabled = true
    }
    
//    for row in 0..<quilt.blocksDown {
//      for column in 0..<quilt.blocksAcross {
//        let quiltBlock = QuiltBlock()
//        quiltBlock.load(quilt[row, column])
//        let imageView = UIImageView(image: quiltBlock.image)
//        let x = column * 100
//        let y = row * 100
//        let frame = CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: 100, height: 100))
//        imageView.frame = frame
//        quiltView.addSubview(imageView)
//        
//        imageView.layer.borderColor = UIColor.blackColor().CGColor
//        imageView.layer.borderWidth = 3
//        
//        //add matrix entry point
//        imageView.tag = row * 1000 + column
//        
//        let tap = UITapGestureRecognizer(target: self, action: "handleBlockTap:")
//        imageView.addGestureRecognizer(tap)
//        imageView.userInteractionEnabled = true
//      }
//    }
  }
  
  func handleBlockTap(gesture:UITapGestureRecognizer) {
    if let view = gesture.view {
      let column = view.tag % gMatrixMultiplier
      let row = (view.tag - column) / gMatrixMultiplier
      println("Column: \(column), Row: \(row)")
      
      let blockID = quilt[row, column]
      let block = Block()
      block.load(blockID)
      
      currentQuiltMatrixID = view.tag
      
      if let controller = storyboard?.instantiateViewControllerWithIdentifier("BlockSelectViewController") as? BlockSelectViewController {
        controller.currentQuilt = quilt
        controller.currentBlock = block
        controller.quiltMatrixID = view.tag
        navigationController?.pushViewController(controller, animated: true)
        
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
  
  @IBAction func exitBlockCancel(segue:UIStoryboardSegue) {
    println("exitBlockCancel")
  }
  
  @IBAction func exitBlockSave(segue:UIStoryboardSegue) {
    println("exitBlockSave")
    
    //TODO: If switchBlocks is on then all blocks with same ID must be updated
    
    if let controller = segue.sourceViewController as? BlockViewController {
      let quiltBlock = controller.quiltBlock
      quiltBlock.image = quiltBlock.buildUserQuiltBlockImage(CGSize(width: 100, height: 100), showPaths: false)
      if let documentID = quiltBlock.documentID {
        quiltBlock.update(documentID)
      } else {
        quiltBlock.save()
      }
      let column = currentQuiltMatrixID % gMatrixMultiplier
      let row = (currentQuiltMatrixID - column) / gMatrixMultiplier

      if self.switchBlocks.on {
        let documentID = quilt[row, column]
        
        quilt.cellVisitor {
          (location: QuiltMatrix) in
          if self.quilt[location] == documentID {
            self.quilt[location] = quiltBlock.documentID!
            let tag = row * gMatrixMultiplier + column
            if let imageView = self.quiltView.viewWithTag(tag) as? UIImageView {
              imageView.image = quiltBlock.image
            }
          }
        }
//        for row in 0..<quilt.blocksDown {
//          for column in 0..<quilt.blocksAcross {
//            if quilt[row, column] == documentID {
//              quilt[row, column] = quiltBlock.documentID!
//              let tag = row * gMatrixMultiplier + column
//              if let imageView = quiltView.viewWithTag(tag) as? UIImageView {
//                imageView.image = quiltBlock.image
//              }
//            }
//          }
//        }
      } else {
        quilt[row, column] = quiltBlock.documentID!
        if let imageView = quiltView.viewWithTag(currentQuiltMatrixID) as? UIImageView {
          imageView.image = quiltBlock.image
        }
      }
    }
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


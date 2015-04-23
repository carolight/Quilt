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
  
  var quiltBlocks:[Block] = []
  var currentScheme:Scheme!
  
  var currentQuiltMatrixID:Int = 0 // This is the entry into the quiltMatrix
                                   // It's tag which is multiplier * row + column + 1
                                   // The + 1 is needed to stop view.tag being zero
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var quiltView: UIView!
  @IBOutlet weak var switchBlocks: UISwitch!
  
  func createNewQuilt() {
    let newQuilt = quilt.copy(currentScheme)
    newQuilt.name = "Mine"
    newQuilt.library = false
    
    newQuilt.save()
    self.quilt = newQuilt
    
    println("Created new quilt")
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
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
    scrollView.maximumZoomScale = 2.0
    scrollView.zoomScale = minScale;
    
    self.automaticallyAdjustsScrollViewInsets = false
    
    //show blocks from quilt matrix
    var blockIDs = Set<String>()
    
    quilt.cellVisitor {
      blockIDs.insert(self.quilt[$0])
    }
    let blockSize = CGSize(width: 100, height: 100)

    var blocks:[Block] = []
    for blockID in blockIDs {
      let block = Block()
      block.load(blockID)
      if block.library {
        block.image = block.buildLibraryQuiltBlockImage(blockSize, scheme: self.quilt.scheme!, showPaths: false)
      } else {
        block.image = block.buildUserQuiltBlockImage(blockSize, showPaths: false)
      }
      blocks.append(block)
    }

    quilt.cellVisitor {
      (location:QuiltMatrix) in
      for block in blocks {
        if self.quilt[location] == block.documentID {
          let imageView = UIImageView(image: block.image)
          let x = location.column * 100
          let y = location.row * 100
          let frame = CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: 100, height: 100))
          imageView.frame = frame
          self.quiltView.addSubview(imageView)
          
          imageView.layer.borderColor = UIColor.blackColor().CGColor
          imageView.layer.borderWidth = 3
          
          //add matrix entry point
          imageView.tag = location.row * 1000 + (location.column + 1)
          
          let tap = UITapGestureRecognizer(target: self, action: "handleBlockTap:")
          imageView.addGestureRecognizer(tap)
          imageView.userInteractionEnabled = true
        }
      }
    }
  }
  
  func handleBlockTap(gesture:UITapGestureRecognizer) {
    if let view = gesture.view {
      let column = (view.tag - 1) % gMatrixMultiplier
      let row = (view.tag - 1 - column) / gMatrixMultiplier
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
      var quiltBlock = controller.block
      quiltBlock.image = quiltBlock.buildUserQuiltBlockImage(CGSize(width: 100, height: 100), showPaths: false)
      
      let column = (currentQuiltMatrixID - 1) % gMatrixMultiplier
      let row = (currentQuiltMatrixID - 1 - column) / gMatrixMultiplier

      var shouldCreateNewBlock = quiltBlock.library
      if !shouldCreateNewBlock {
        //should create new block is all blocks is off and 
        //if the original block is used by other blocks
        //otherwise write over original block
        
        if !switchBlocks.on {
          quilt.cellVisitor {
            (location: QuiltMatrix) in
            if location.row != row && location.column != column {
              if quiltBlock.documentID == self.quilt[location] {
                shouldCreateNewBlock = true
                return
              }
            }
          }
        }
      }
    
      if shouldCreateNewBlock {
        let newBlock = quiltBlock.copy()
        newBlock.library = false
        newBlock.quiltID = quilt.documentID
        newBlock.save()
        quiltBlock = newBlock
      } else {
        if let documentID = quiltBlock.documentID {
          quiltBlock.update(documentID)
        } else {
          quiltBlock.save()
        }
      }
      
      if self.switchBlocks.on {
        let documentID = quilt[row, column]
        
        quilt.cellVisitor {
          (location: QuiltMatrix) in
          if self.quilt[location] == documentID {
            self.quilt[location] = quiltBlock.documentID!
            let tag = location.row * gMatrixMultiplier + (location.column + 1)
            println("tag: \(tag)")
            if let imageView = self.quiltView.viewWithTag(tag) as? UIImageView {
              imageView.image = quiltBlock.image
            }
          }
        }
      } else {
        println("saving \(column) : \(row)")
        quilt[row, column] = quiltBlock.documentID!
        if let imageView = quiltView.viewWithTag(currentQuiltMatrixID) as? UIImageView {
          imageView.image = quiltBlock.image
        }
      }
      quilt.update(quilt.documentID!)
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


//
//  BlockViewController.swift
//  Quilt
//
//  Created by Caroline Begbie on 2/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//


//For when user selects block in BlockSelectViewController.
//In this screen, a User Block is always worked on

import UIKit

class BlockViewController: UIViewController {
  
  var block: Block!
  
  var selectedPatchColor:Int? = nil
  
  @IBOutlet weak var blockView: BlockView!
  
  @IBOutlet weak var scrollView: UIScrollView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    blockView.image = block.image
    
    blockView.loadPatchColors(fromBlock: block)
    
    blockView.delegate = self
    blockView.patches = block.patches
    blockView.patchColors = block.patchColors
    
    scrollView.delegate = self
    
    scrollView.contentSize = blockView.bounds.size
    
    let scrollViewFrame = scrollView.frame
    let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
    let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
    let minScale = min(scaleWidth, scaleHeight);
    scrollView.minimumZoomScale = minScale;
    
    // 5
    scrollView.maximumZoomScale = 2.0
    scrollView.zoomScale = minScale;
    
    self.automaticallyAdjustsScrollViewInsets = false
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  func centerScrollViewContents() {
    return
    let boundsSize = scrollView.bounds.size
    var contentsFrame = blockView.frame
    
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
    
    blockView.frame = contentsFrame
  }
  
  //  @IBAction func btnCancel(sender: AnyObject) {
  //    println("cancel")
  ////    dismissViewControllerAnimated(true, completion: nil)
  //  }
  //  @IBAction func btnSave(sender: AnyObject) {
  //    println("xx save")
  //
  //    UIGraphicsBeginImageContextWithOptions(blockView.bounds.size, view.opaque, 0.0)
  //    blockView.drawViewHierarchyInRect(blockView.bounds, afterScreenUpdates: true)
  //    let image = UIGraphicsGetImageFromCurrentImageContext()
  //    UIGraphicsEndImageContext()
  //
  //    block.image = image
  //
  //    //create image
  //    //update quilt block in file
  //    //update quilt image
  //
  ////    dismissViewControllerAnimated(true, completion: nil)
  //  }
}

extension BlockViewController: UIScrollViewDelegate {
  func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
    return blockView
  }
  
  func scrollViewDidZoom(scrollView: UIScrollView) {
    centerScrollViewContents()
  }
}

extension BlockViewController: BlockViewDelegate {
  func blockViewShouldShowFabric(blockView: BlockView, location: CGPoint) {
    //test to see which one tapped
    
    for (index, patch) in enumerate(blockView.patches) {
      if patch.path.containsPoint(location) {
        selectedPatchColor = block.patchColors[index]
        break
      }
    }
    
    if let collectionViewController = storyboard?.instantiateViewControllerWithIdentifier("FabricCollectionViewController") as? FabricCollectionViewController {
      collectionViewController.delegate = self
      navigationController?.pushViewController(collectionViewController, animated: true)
    }
    
    
    return
    
    
    if let collectionViewController = storyboard?.instantiateViewControllerWithIdentifier("CollectionViewController") as? CollectionViewController {
      collectionViewController.appState = .Fabric
      collectionViewController.delegate = self
      
      var fabricsPath = NSBundle.mainBundle().resourcePath!
      fabricsPath = fabricsPath.stringByAppendingString("/fabrics/")
      let manager = NSFileManager.defaultManager()
      let directoryEnum = manager.enumeratorAtPath(fabricsPath)
      while let file = directoryEnum?.nextObject() as? String {
        let filename = fabricsPath.stringByAppendingString(file)
        if let image = UIImage(contentsOfFile: filename) {
          let fabric = Fabric()
          fabric.name = file
          fabric.image = image
          collectionViewController.array.append(fabric)
        }
      }
      
      navigationController?.pushViewController(collectionViewController, animated: true)
      
    }
  }
}

extension BlockViewController:FabricCollectionViewControllerDelegate {
  func didSelectFabric(fabric: Fabric) {
    println("didSelectFabric: \(fabric.name)")
    if block.blockFabrics.count < block.patches.count {
      block.blockFabrics = [String](count: block.patches.count, repeatedValue: " ")
    }
    if let fabricImage = fabric.image  {
      if let selectedColor = selectedPatchColor {
        for (index, color) in enumerate(block.patchColors) {
          if color == selectedColor {
            let path = block.patches[index].path
            let fabricColor = UIColor(patternImage: fabricImage)
            block.patches[index].color = fabricColor
            block.patches[index].fabric = fabric
            
            block.blockFabrics[index] = fabric.name
          }
        }
        blockView.setNeedsDisplay()
      }
    }
    navigationController?.popViewControllerAnimated(true)
  }

}

extension BlockViewController: CollectionViewControllerDelegate {
  func didSelectItem(item: AnyObject) {
    if block.blockFabrics.count < block.patches.count {
      block.blockFabrics = [String](count: block.patches.count, repeatedValue: " ")
    }
    if let fabric = item as? Fabric {
      if let fabricImage = fabric.image  {
        if let selectedColor = selectedPatchColor {
          for (index, color) in enumerate(block.patchColors) {
            if color == selectedColor {
              let path = block.patches[index].path
              let fabricColor = UIColor(patternImage: fabricImage)
              block.patches[index].color = fabricColor
              block.patches[index].fabric = fabric
              
              block.blockFabrics[index] = fabric.name
            }
          }
          blockView.setNeedsDisplay()
        }
      }
    }
  }
  
  func didScrollToItem(item: AnyObject) {
    if let block = item as? Block {
      println("did scroll to \(block.name)")
    }
  }
  
  func didBeginDragging() {
    
  }
}
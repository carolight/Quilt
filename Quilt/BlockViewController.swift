//
//  BlockViewController.swift
//  Quilt
//
//  Created by Caroline Begbie on 2/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import UIKit

class BlockViewController: UIViewController {
  
  var block:Block!
  
  var selectedPatchColor:Int? = nil
  
  @IBOutlet weak var blockView: BlockView!
  
  @IBOutlet weak var scrollView: UIScrollView!

  
    override func viewDidLoad() {
        super.viewDidLoad()
  
      blockView.image = block.image
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  func centerScrollViewContents() {
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

  @IBAction func btnCancel(sender: AnyObject) {
    println("cancel")
    dismissViewControllerAnimated(true, completion: nil)
  }
  @IBAction func btnSave(sender: AnyObject) {
    println("save")
    dismissViewControllerAnimated(true, completion: nil)
  }
}

extension BlockViewController: UIScrollViewDelegate {
  func viewForZoomingInScrollView(scrollView: UIScrollView!) -> UIView! {
    return blockView
  }
  
  func scrollViewDidZoom(scrollView: UIScrollView!) {
    centerScrollViewContents()
  }
}

extension BlockViewController: BlockViewDelegate {
  func blockViewShouldShowFabric(blockView: BlockView, location: CGPoint) {
//    if let fabricViewController = storyboard?.instantiateViewControllerWithIdentifier("FabricViewController") as? FabricViewController {
////      if let image = getBlockImage(location) {
////        blockViewController.image = image
////      }
//      navigationController?.pushViewController(fabricViewController, animated: true)
//    }
    
    //test to see which one tapped

    for (index, patch) in enumerate(blockView.patches) {
      if patch.path.containsPoint(location) {
        println("found")
        println(block.patchColors[index])
        selectedPatchColor = block.patchColors[index]
        break
      }
    }
    
    
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
          collectionViewController.array.append(image)
        }
      }
      
      navigationController?.pushViewController(collectionViewController, animated: true)
      
    }


  }
}

extension BlockViewController: CollectionViewControllerDelegate {
  func didSelectItem(item: AnyObject) {
    println("didSelectItem")
    if let fabricImage = item as? UIImage {
      if let selectedColor = selectedPatchColor {
        for (index, color) in enumerate(block.patchColors) {
          if color == selectedColor {
            
            let path = block.patches[index].path
            let fabricColor = UIColor(patternImage: fabricImage)
            block.patches[index].color = fabricColor
          }
        }
        blockView.setNeedsDisplay()
      }
    }
  }
}
//
//  BlockViewController.swift
//  Quilt
//
//  Created by Caroline Begbie on 2/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import UIKit

class BlockViewController: UIViewController {
  
  var image = UIImage(named: "block1.jpg")
  @IBOutlet weak var blockView: BlockView!
  
  @IBOutlet weak var scrollView: UIScrollView!

  
    override func viewDidLoad() {
        super.viewDidLoad()
  
      blockView.image = image
      
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

}

extension BlockViewController: UIScrollViewDelegate {
  func viewForZoomingInScrollView(scrollView: UIScrollView!) -> UIView! {
    println("viewForZoomingInScrollView")
    return blockView
  }
  
  func scrollViewDidZoom(scrollView: UIScrollView!) {
    centerScrollViewContents()
  }
}

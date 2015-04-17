//
//  QuiltCollectionViewCell.swift
//  Quilt
//
//  Created by Caroline Begbie on 1/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import UIKit

class QuiltCollectionViewCell: UICollectionViewCell {

 
  @IBOutlet weak var imageView: UIImageView!
  
  var tapGesture:UITapGestureRecognizer!
  var swipeGesture:UISwipeGestureRecognizer!
  
  let optionsView = UIView()
  var isOptions = false
  
  func setupOptionsView() {
    optionsView.frame = imageView.frame
    optionsView.backgroundColor = UIColor.redColor()
    if let superview = imageView.superview {
      superview.addSubview(optionsView)
      superview.sendSubviewToBack(optionsView)
    }
    

  }
  

  
  func handleTap(gesture: UITapGestureRecognizer) {
    println("tap")
  }

  func handleSwipe(gesture: UISwipeGestureRecognizer) {
    
    if isOptions {
      imageView.addGestureRecognizer(swipeGesture)
      UIView.transitionFromView(optionsView,
        toView: imageView,
        duration: 1.0,
        options: UIViewAnimationOptions.TransitionFlipFromTop
          | UIViewAnimationOptions.ShowHideTransitionViews,
        completion:nil)
      
    } else {
      
      optionsView.addGestureRecognizer(swipeGesture)
      
      UIView.transitionFromView(imageView,
        toView: optionsView,
        duration: 1.0,
        options: UIViewAnimationOptions.TransitionFlipFromBottom
          | UIViewAnimationOptions.ShowHideTransitionViews,
        completion: nil)
    }
    
    isOptions = !isOptions
    
  }

}


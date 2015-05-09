//
//  Categories.swift
//  Quilt
//
//  Created by Caroline Begbie on 7/05/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import Foundation


extension UINavigationController {
  
  func pushFadeViewController(viewController:UIViewController) {
    fadeTransition()
    pushViewController(viewController, animated: false)
  }
 
  func popFadeViewController() {
    fadeTransition()
    popViewControllerAnimated(false)
  }
  
  func popToRootFadeViewController() {
    fadeTransition()
    popToRootViewControllerAnimated(false)
  }
  
  func fadeTransition() {
    let transition = CATransition()
    transition.duration = 0.3
    transition.type = kCATransitionFade
    self.view.layer.addAnimation(transition, forKey: nil)
  }
}
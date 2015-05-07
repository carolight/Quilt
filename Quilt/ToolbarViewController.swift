//
//  ToolbarViewController.swift
//  Quilt
//
//  Created by Caroline Begbie on 7/05/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import UIKit

enum QuiltToolBar:Int {
  case Rotate=1, FlipHorizontal, FlipVertical, Block, Options
}

protocol ToolbarViewControllerDelegate {

  func toolRotateBlock()
  func toolFlipBlockHorizontal()
  func toolFlipBlockVertical()
  func toolBlock()
  func toolOptions()
  
  
}

class ToolbarViewController: UIViewController {

  var delegate:ToolbarViewControllerDelegate? = nil
  
  var currentTool: QuiltToolBar = .Block {
    didSet {
      for i in 1...5 {
        if let view = self.view.viewWithTag(i) {
          if currentTool.rawValue == i {
            view.backgroundColor = UIColor.redColor()
          } else {
            view.backgroundColor = UIColor.clearColor()
          }
        }
      }
    }
  }
  
    override func viewDidLoad() {
      
        super.viewDidLoad()
      currentTool = .Block

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  @IBAction func btnPressed(sender:UIButton) {
    
    for i in 1...5 {
      if let view = self.view.viewWithTag(i) {
        view.backgroundColor = UIColor.clearColor()
      }
    }
    
    switch sender.tag {
    case 1:
      delegate?.toolRotateBlock()
    case 2:
      delegate?.toolFlipBlockHorizontal()
    case 3:
      delegate?.toolFlipBlockVertical()
    case 4:
      delegate?.toolBlock()
    case 5:
      delegate?.toolOptions()
    default: ()
    }
    
    sender.backgroundColor = UIColor.redColor()
   
    if let value = QuiltToolBar(rawValue: sender.tag) {
      currentTool = value
    }
  }
}

//
//  CreateBlockPatchEditViewController.swift
//  Quilt
//
//  Created by Caroline Begbie on 8/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import UIKit

protocol CreateBlockPatchEditViewControllerDelegate {
  func createBlockPatchEditViewControllerDidUpdate(point:CGPoint, indexPath:NSIndexPath)
}

class CreateBlockPatchEditViewController: UIViewController {

  @IBOutlet weak var xPoint: UITextField!
  @IBOutlet weak var yPoint: UITextField!
  
  var point:CGPoint = CGPointZero
  var indexPath:NSIndexPath!
  
  var delegate:CreateBlockPatchEditViewControllerDelegate? = nil
  
    override func viewDidLoad() {
        super.viewDidLoad()
      xPoint.text = "\(point.x)"
      yPoint.text = "\(point.y)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CreateBlockPatchEditViewController:UITextFieldDelegate {
  func textFieldDidEndEditing(textField: UITextField) {
    var resultX = CGFloat((xPoint.text as NSString).floatValue)
    var resultY = CGFloat((yPoint.text as NSString).floatValue)
    
    resultX = ceil(resultX * 100)
    resultY = ceil(resultY * 100)
    
    point = CGPoint(x: resultX / 100, y: resultY / 100)

    
    self.delegate?.createBlockPatchEditViewControllerDidUpdate(point, indexPath:indexPath)
  }
}
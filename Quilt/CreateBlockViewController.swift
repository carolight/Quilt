//
//  CreateBlockViewController.swift
//  Quilt
//
//  Created by Caroline Begbie on 7/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import UIKit

//class CreatePatch {
//  var points:[CGPoint] = []
//}

class CreateBlockViewController: UIViewController {
  
  enum AppState {
    case New, Close, Edit
  }
  
  @IBOutlet weak var createBlockView: CreateBlockView!
  @IBOutlet weak var blockName: UITextField!
  
  var result = CGPointZero

  var path = UIBezierPath()
  var paths:[UIBezierPath] = []
  
  var appState:AppState = .Close
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    println("viewDidAppear")
    self.createBlockView.setNeedsDisplay()
  }
  
  func handleTap(gesture:UITapGestureRecognizer) {
    if appState != .Edit {
      return
    }
    let touchPoint = gesture.locationInView(gesture.view)
    let width = createBlockView.bounds.width
    for patch in createBlockView.patches {
      var path = UIBezierPath()
      var first = true
      for point in patch.points {
        let location = CGPoint(x: point.x * width, y: point.y * width)
        if first {
          path.moveToPoint(location)
          first = false
        } else {
          path.addLineToPoint(location)
        }
      }
      path.closePath()
      if path.containsPoint(touchPoint) {
        if let patchViewController = self.storyboard?.instantiateViewControllerWithIdentifier("CreateBlockPointsTableViewController") as? CreateBlockPointTableViewController {
          self.navigationController?.pushViewController(patchViewController, animated: true)
          
        }
      }
    }
    println("tap")
  }
//  func handlePan(gesture:UIPanGestureRecognizer) {
//    switch gesture.state {
//      
//    case .Ended:
//      println("final result: \(result)")
//      if let patch = patch {
//        patch.points.append(result)
//      }
//      
//    default:
//      if let view = gesture.view {
//        let location = gesture.locationInView(view)
//        let width = view.bounds.width
//        
//        var resultX = location.x / width
//        var resultY = location.y / width
//        
//        resultX = ceil(resultX * 100)
//        resultY = ceil(resultY * 100)
//        
//        result = CGPoint(x: resultX / 100, y: resultY / 100)
//        
//        println(result)
//      }
//      
//      
//    }
//  }
  
  @IBAction func btnNewPath(sender:UIButton) {
    self.title = "New Path"
    appState = .New
    createBlockView.allowEdit = true
    createBlockView.patch = Patch()
  }
  
  @IBAction func btnClosePath(sender:UIButton) {
    self.title = "No Path"
    createBlockView.allowEdit = false
    appState = .Close
    if let patch = createBlockView.patch {
      createBlockView.patches.append(patch)
    }
    createBlockView.setNeedsDisplay()
  }
  
  @IBAction func btnSave(sender:UIButton) {
    var block = Block()
    block.name = blockName.text
    block.patches = createBlockView.patches
    block.image = block.createImage()

    for (index, patch) in enumerate(block.patches) {
      block.patchColors.append(index)
    }
    
    block.save()
    block.saveToPlist()
  }
  
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "CreateBlockEdit" {
      println("edit")
      let controller = segue.destinationViewController as CreateBlockPointTableViewController
      controller.patches = createBlockView.patches
      
    }
  }
  
}

extension CreateBlockViewController:UITextFieldDelegate {
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    println("return")
    textField.resignFirstResponder()
    return true
  }
  func textFieldDidEndEditing(textField: UITextField) {
    println("end editing")
    self.title = textField.text
    textField.resignFirstResponder()
  }
}

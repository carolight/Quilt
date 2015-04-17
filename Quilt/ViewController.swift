//
//  ViewController.swift
//  Quilt
//
//  Created by Caroline Begbie on 1/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  @IBOutlet var quiltSegmentedControl:UISegmentedControl!
  
  var collectionViewController:CollectionViewController? = nil
  var schemeCollectionViewController:SchemeCollectionViewController? = nil
  
  @IBOutlet weak var schemeContainerView: UIView!
  
  var quiltTitle = UILabel() // this goes at top of screen
  
  @IBOutlet weak var quiltTitleLabel: UILabel! // this is the title of the user quilt
  
  var isLibraryQuilt: Bool {
    get {
      return quiltSegmentedControl.selectedSegmentIndex == 1
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Select Quilt"
    
    quiltTitle.frame = quiltSegmentedControl.frame
    quiltTitle.text = "Select Quilt"
    quiltTitle.textAlignment = .Center
    quiltTitle.hidden = true
    quiltSegmentedControl.superview?.addSubview(quiltTitle)
   
    quiltTitleLabel.text = "Untitled"
    
  }
  
  func loadQuiltsArray() {
    if let collectionViewController = collectionViewController {
      collectionViewController.array = []
      let query = database.viewNamed("quilts").createQuery()
      var error:NSError?
      let result = query.run(&error)
      while let row = result?.nextRow() {
        let quilt = Quilt()
        println("loading quilt from loadQuiltsArray")
        quilt.load(row.documentID)
        if quilt.library == isLibraryQuilt {
          collectionViewController.array.append(quilt)
        }
      }
    }
  }
  
  func checkQuiltType() {
    if !isLibraryQuilt && collectionViewController?.array.count == 0 {
      quiltSegmentedControl.selectedSegmentIndex = 1
      quiltSegmentedControl.hidden = true
      quiltTitle.hidden = false
      schemeContainerView.hidden = false
      loadQuiltsArray()
    } else {
      quiltSegmentedControl.hidden = false
      quiltTitle.hidden = true
      schemeContainerView.hidden = true
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    quiltTitle.hidden = true
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if let collectionViewController = collectionViewController {
      let isLibrary = (quiltSegmentedControl.selectedSegmentIndex == 1)
      loadQuiltsArray()
      checkQuiltType()
      collectionViewController.collectionView?.reloadData()
    }
//    if let schemeCollectionViewController = schemeCollectionViewController {
//      schemeCollectionViewController.schemes = []
//      let query = database.viewNamed("schemes").createQuery()
//      var error:NSError?
//      let result = query.run(&error)
//      while let row = result?.nextRow() {
//        let scheme = Scheme()
//        println("loading scheme from viewWillAppear")
//        scheme.load(row.documentID)
//        schemeCollectionViewController.schemes.append(scheme)
//      }
//
//      schemeCollectionViewController.collectionView?.reloadData()
//    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "QuiltCollectionViewController" {
      if let collectionViewController = segue.destinationViewController as? CollectionViewController {
        self.collectionViewController = collectionViewController
        collectionViewController.appState = .Quilt
      }
    }
    if segue.identifier == "SchemeCollectionViewController" {
      if let controller = segue.destinationViewController as? SchemeCollectionViewController {
        controller.delegate = self
        schemeCollectionViewController = controller
      }
    }
  }
  
  @IBAction func quiltSegmentedControlDidChange(sender: UISegmentedControl) {
    schemeContainerView.hidden = !isLibraryQuilt
    loadQuiltsArray()
    collectionViewController?.collectionView?.reloadData()
    
  }

}

extension ViewController: SchemeCollectionViewControllerDelegate {
  func didSelectColorScheme(scheme: Scheme) {
    self.collectionViewController?.selectedScheme = scheme
    self.collectionViewController?.collectionView?.reloadData()
  }
}
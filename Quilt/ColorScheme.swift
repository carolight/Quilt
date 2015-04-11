//
//  ColorScheme.swift
//  Quilt
//
//  Created by Caroline Begbie on 11/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import Foundation

class ColorScheme {
  
  //saved
  
  var fabrics:[String] = [] //filename pointer to files
  
  //not saved
  
  var fabricImages:[UIImage] = [] //loaded using fabrics from file
  var documentID: String? = nil
  
  func save() {
    let properties = ["type": "Scheme",
      "fabrics": fabrics]
    
    let document = database.createDocument()
    var error:NSError?
    
    if document.putProperties(properties as [NSObject : AnyObject], error: &error) == nil {
      println("couldn't save new item \(error?.localizedDescription)")
    }
  }

}
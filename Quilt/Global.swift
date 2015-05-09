//
//  Global.swift
//  Quilt
//
//  Created by Caroline Begbie on 18/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import Foundation


var _gSelectedScheme:Scheme? = nil
var gSelectedScheme:Scheme? {
get {
  if _gSelectedScheme == nil {
    //get first color scheme
    let query = database.viewNamed("schemes").createQuery()
    var error:NSError?
    let result = query.run(&error)
    var scheme = Scheme()
    while let row = result?.nextRow() {
      scheme.load(row.documentID)
      break
    }
    _gSelectedScheme = scheme
  }
  return _gSelectedScheme
}
  set {
    _gSelectedScheme = newValue
  }
}


//for entry into quilt matrix
let gMatrixMultiplier = 1000

//example of use:

//add matrix entry point
//imageView.tag = row * gMatrixMultiplier + column

//extract matrix entry point
//let column = imageView.tag % gMatrixMultiplier
//let row = (imageView.tag - column) / gMatrixMultiplier

let gQuiltThumbnailSize = CGSize(width: 240, height: 400)

let IPAD = UI_USER_INTERFACE_IDIOM() == .Pad

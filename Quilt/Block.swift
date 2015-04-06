//
//  Block.swift
//  Quilt
//
//  Created by Caroline Begbie on 3/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import Foundation
import UIKit

class Block  {
  var name:String = " "
  var image:UIImage? = nil
  var patches:[Patch] = []
  var patchColors:[Int] = []
}

class Patch {
  var points:[CGPoint] = []
  var color: UIColor = UIColor.blueColor()
  var path: UIBezierPath = UIBezierPath()
}
//
//  Global.swift
//  Quilt
//
//  Created by Caroline Begbie on 18/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import Foundation


var gSelectedScheme:Scheme!


//for entry into quilt matrix
let gMatrixMultiplier = 1000

//example of use:

//add matrix entry point
//imageView.tag = row * gMatrixMultiplier + column

//extract matrix entry point
//let column = imageView.tag % gMatrixMultiplier
//let row = (imageView.tag - column) / gMatrixMultiplier
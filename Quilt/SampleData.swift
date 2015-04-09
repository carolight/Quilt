//
//  SampleData.swift
//  Quilt
//
//  Created by Caroline Begbie on 3/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import Foundation
import UIKit

var quilts:[Quilt] = []
var blocks:[Block] = []
var fabrics:[Fabric] = []

func setupQuilts() {
  var quiltSize = CGSize(width:240, height:400)
  var blockSize = CGSize(width: 40, height: 40)
  var blocksAcross = 5
  var blocksDown = 9
  var borderWidth:CGFloat = 20
  
  blockSize.width = (quiltSize.width - borderWidth*2) / CGFloat(blocksAcross)
  blockSize.height = blockSize.width
  
  var quilt = Quilt()
  quilt.blocksAcross = blocksAcross
  quilt.blocksDown = blocksDown
  
  var rect = CGRect(origin: CGPointZero, size: quiltSize)
  
  quilt.name = "untitled 1"
  quilt.blockSize = blockSize
  quilt.library = true
  
  
  UIGraphicsBeginImageContextWithOptions(quiltSize, true, 0)
  let context = UIGraphicsGetCurrentContext()
  UIColor.whiteColor().setFill()
  UIColor.blackColor().setStroke()
  
//  top border
  var path = UIBezierPath(rect: rect)
  path.fill()
  rect.size.height = borderWidth
  path = UIBezierPath(rect: rect)
  path.stroke()
  
  //  bottom border
  rect.origin.y = quiltSize.height - borderWidth
  path = UIBezierPath(rect: rect)
  path.stroke()

  
//  left border
  rect.origin.y = borderWidth
  rect.size.width = borderWidth
  rect.size.height = quiltSize.height - borderWidth*2
  path = UIBezierPath(rect: rect)
  path.stroke()

//  right border
  rect.origin.x = quiltSize.width - borderWidth
  path = UIBezierPath(rect: rect)
  path.stroke()
  
  rect.size = blockSize
  for column in 0..<blocksAcross {
    for row in 0..<blocksDown {
      rect.origin.x = CGFloat(column) * blockSize.width + borderWidth
      rect.origin.y = CGFloat(row) * blockSize.height + borderWidth
      path = UIBezierPath(rect: rect)
      UIColor.yellowColor().setFill()
//      path.stroke()
      path.fill()
      quilt.blockPaths.append(path)

    }
  }

  
  let image = UIGraphicsGetImageFromCurrentImageContext()
  UIGraphicsEndImageContext()
  
  quilt.image = image
  quilts.append(quilt)
  quilt.save()
  
}


func setupBlocks() {
  
  var blocksPath = NSBundle.mainBundle().resourcePath!
  blocksPath = blocksPath.stringByAppendingString("/blocks/")
  var patch:Patch
  var point:CGPoint
  
  var block = Block()
  block.name = "Ladies Beautiful Star"
  var filename = blocksPath.stringByAppendingString("block1.png")
  block.image = UIImage(contentsOfFile: filename)
  blocks.append(block)
  
  block = Block()
  block.name = "Star of Many Points"
  filename = blocksPath.stringByAppendingString("block2.png")
  block.image = UIImage(contentsOfFile: filename)
  blocks.append(block)
  
  block = Block()
  block.name = "Star of Bethlehem"
  filename = blocksPath.stringByAppendingString("block3.png")
  block.image = UIImage(contentsOfFile: filename)

  //1
  patch = Patch()
  patch.points = [CGPointMake(0.0, 0.0),
                  CGPointMake(0.5, 0.0),
                  CGPointMake(0.33, 0.25),
                  CGPointMake(0.0, 0.25)]
  block.patches.append(patch)
  block.patchColors.append(0)

  //2
  patch = Patch()
  patch.points = [CGPointMake(0.5, 0.0),
    CGPointMake(0.66, 0.25),
    CGPointMake(0.33, 0.25)]
  block.patches.append(patch)
  block.patchColors.append(1)

  //3
  patch = Patch()
  patch.points = [CGPointMake(0.5, 0.0),
    CGPointMake(1, 0.0),
    CGPointMake(1, 0.25),
    CGPointMake(0.66, 0.25)]
  block.patches.append(patch)
  block.patchColors.append(0)

  //4
  patch = Patch()
  patch.points = [CGPointMake(0.0, 0.25),
    CGPointMake(0.33, 0.25),
    CGPointMake(0.25, 0.5)]
  block.patches.append(patch)
  block.patchColors.append(1)

  //5
  patch = Patch()
  patch.points = [CGPointMake(0.33, 0.25),
    CGPointMake(0.66, 0.25),
    CGPointMake(0.75, 0.5),
    CGPointMake(0.66, 0.75),
    CGPointMake(0.33, 0.75),
    CGPointMake(0.25, 0.5)]
  
  block.patches.append(patch)
  block.patchColors.append(2)

  //6
  patch = Patch()
  patch.points = [CGPointMake(0.66, 0.25),
    CGPointMake(1, 0.25),
    CGPointMake(0.75, 0.5)]
  block.patches.append(patch)
  block.patchColors.append(1)
  
  //7
  patch = Patch()
  patch.points = [CGPointMake(0, 0.25),
    CGPointMake(0.25, 0.5),
    CGPointMake(0, 0.75)]
  block.patches.append(patch)
  block.patchColors.append(0)

  //8
  patch = Patch()
  patch.points = [CGPointMake(1, 0.25),
    CGPointMake(0.75, 0.5),
    CGPointMake(1, 0.75)]
  block.patches.append(patch)
  block.patchColors.append(0)

  //9
  patch = Patch()
  patch.points = [CGPointMake(0, 0.75),
    CGPointMake(0.25, 0.5),
    CGPointMake(0.33, 0.75)]
  block.patches.append(patch)
  block.patchColors.append(1)
  
  //10
  patch = Patch()
  patch.points = [CGPointMake(0.75, 0.5),
    CGPointMake(1, 0.75),
    CGPointMake(0.66, 0.75)]
  block.patches.append(patch)
  block.patchColors.append(1)

  
  //11
  patch = Patch()
  patch.points = [CGPointMake(0.0, 0.75),
    CGPointMake(0.33, 0.75),
    CGPointMake(0.5, 1),
    CGPointMake(0.0, 1)]
  block.patches.append(patch)
  block.patchColors.append(0)
  
  //12
  patch = Patch()
  patch.points = [CGPointMake(0.33, 0.75),
    CGPointMake(0.66, 0.75),
    CGPointMake(0.5, 1)]
  block.patches.append(patch)
  block.patchColors.append(1)

  //13
  patch = Patch()
  patch.points = [CGPointMake(0.66, 0.75),
    CGPointMake(1, 0.75),
    CGPointMake(1, 1),
    CGPointMake(0.5, 1)]
  block.patches.append(patch)
  block.patchColors.append(0)
  
  
  
  
  
  

  blocks.append(block)

  block = Block()
  block.name = "Rolling Star"
  filename = blocksPath.stringByAppendingString("block4.png")
  block.image = UIImage(contentsOfFile: filename)
  blocks.append(block)

  block = Block()
  block.name = "Evening Star"
  filename = blocksPath.stringByAppendingString("block5.png")
  block.image = UIImage(contentsOfFile: filename)
  blocks.append(block)

  block = Block()
  block.name = "Star and Chains"
  filename = blocksPath.stringByAppendingString("block6.png")
  block.image = UIImage(contentsOfFile: filename)
  blocks.append(block)

  block = Block()
  block.name = "Morning Star"
  filename = blocksPath.stringByAppendingString("block7.png")
  block.image = UIImage(contentsOfFile: filename)
  blocks.append(block)

  block = Block()
  block.name = "Seven Stars"
  filename = blocksPath.stringByAppendingString("block8.png")
  block.image = UIImage(contentsOfFile: filename)
  blocks.append(block)

  block = Block()
  block.name = "Feather Star"
  filename = blocksPath.stringByAppendingString("block9.png")
  block.image = UIImage(contentsOfFile: filename)
  blocks.append(block)

  block = Block()
  block.name = "Star Puzzle"
  filename = blocksPath.stringByAppendingString("block10.png")
  block.image = UIImage(contentsOfFile: filename)
  blocks.append(block)

  
}

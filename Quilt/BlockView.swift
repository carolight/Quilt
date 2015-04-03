//
//  BlockView.swift
//  Quilt
//
//  Created by Caroline Begbie on 2/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import UIKit

class BlockView: UIView {

  var image:UIImage!
    override func drawRect(rect: CGRect) {
      
      image.drawInRect(rect)
    }

}

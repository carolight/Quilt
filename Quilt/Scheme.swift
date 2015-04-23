//
//  ColorScheme.swift
//  Quilt
//
//  Created by Caroline Begbie on 11/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import Foundation

class Scheme {
  
  var type:CollectionType = .Scheme
  
  //saved
  var name = "untitled"
  var image:UIImage? = nil
  var fabrics:[String] = [] //filename pointer to files
  
  //not saved
  
  var fabricImages:[UIImage] = [] //loaded using fabrics from file
  var documentID: String? = nil
  
  
  
  func loadFabricImages() {
    var fabricsPath = NSBundle.mainBundle().resourcePath!
    fabricsPath = fabricsPath.stringByAppendingString("/fabrics/")
    fabricImages = []
    for fabric in fabrics {
      let filename = fabricsPath.stringByAppendingPathComponent(fabric)
      if let image = UIImage(contentsOfFile: filename) {
        fabricImages.append(image)
      }
    }
  }
  
  func createThumbnail() -> UIImage {
    let size = CGSize(width: 200, height: 200)
    let rect = CGRect(origin: CGPointZero, size: size)
    UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
    let context = UIGraphicsGetCurrentContext()
    
    UIColor.whiteColor().setFill()
    CGContextFillRect(context, rect)

    let offset = size.width / CGFloat(fabricImages.count)
    var newRect = rect
    for (index, image) in enumerate(fabricImages) {
      image.drawInRect(newRect)
      newRect.origin.x += offset
    }

    var image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
  }
}

extension Scheme: DatabaseProtocol {
  func save() {
    let properties = ["type": "Scheme",
      "name": name,
      "fabrics": fabrics]
    
//    let document = database.createDocument()
//    var error:NSError?
//    
//    if document.putProperties(properties as [NSObject : AnyObject], error: &error) == nil {
//      println("couldn't save new item \(error?.localizedDescription)")
//    }
    
    let document = gSave(properties)
    var error:NSError?

    self.image = createThumbnail()
    
    var newRevision = document.currentRevision.createRevision()
    let imageData = UIImagePNGRepresentation(image)
    newRevision.setAttachmentNamed("image.png", withContentType: "image/png", content: imageData)
    assert(newRevision.save(&error) != nil)
    
    self.documentID = document.documentID
  }

  func load(documentID:String) {
    println("Loading Scheme: \(documentID)")
    self.documentID = documentID
    
    let document = database.documentWithID(documentID)
    if let name = document["name"] as? String {
      self.name = name
    }
    if let fabrics = document["fabrics"] as? [String] {
      self.fabrics = fabrics
    }
    
    if let revision = document.currentRevision {
      if let imageData = revision.attachmentNamed("image.png") {
        if let image = UIImage(data: imageData.content, scale: UIScreen.mainScreen().scale) {
          self.image = image
        }
      }
    }
    
    if image == nil {
      println("Error: Scheme Image is missing")

    }
  }

  func update(documentID: String) {
    println ("Scheme update not yet implemented")
  }
}


//
//  DatabaseProtocol.swift
//  Quilt
//
//  Created by Caroline Begbie on 20/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import Foundation

enum CollectionType {
  case Quilt, Block, Scheme, Fabric
}

protocol DatabaseProtocol {
  var type:CollectionType { get }
  func save()
  func update(documentID: String)
  func load(documentID: String)
}

func gSave(properties:NSDictionary) -> CBLDocument {
  let document = database.createDocument()
  var error:NSError?
  if document.putProperties(properties as [NSObject : AnyObject], error: &error) == nil {
    println("couldn't save new item \(error?.localizedDescription)")
  }
  return document
}
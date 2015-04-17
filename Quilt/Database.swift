//
//  Database'.swift
//  Quilt
//
//  Created by Caroline Begbie on 7/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import Foundation

var manager:CBLManager!
var database:CBLDatabase!

func createDB(name:String) -> Bool{
  manager = CBLManager.sharedInstance()
  
  if !(CBLManager.isValidDatabaseName(name)) {
    println("Invalid Database Name")
    return false
  }
  
  var error:NSError? = nil
  
  if let newDatabase = manager.databaseNamed(name, error: &error) {
    let homeDirectory = NSHomeDirectory()
    let databaseLocation = "\(NSHomeDirectory())/Library/Application Support/CouchbaseLite"
    println("Database \(name) created at \(databaseLocation)")
    database = newDatabase
    return true
  } else {
    println("Can't create database. Error: \(error?.localizedDescription)")
    return false
  }
  
}

func createViews() {
  
  database.viewNamed("quiltBlocks").setMapBlock("1") {
    (document, emit) in
    if document["type"] as? String == "QB" {
      emit(document["quiltID"], nil)
    }
  }
  
  database.viewNamed("blocks").setMapBlock("1") {
    (document, emit) in
    if document["type"] as? String == "Block" {
      if let name = document["name"] as? String {
        emit(name, document)
      }
    }
  }

  database.viewNamed("quilts").setMapBlock("1") {
    (document, emit) in
    if document["type"] as? String == "Quilt" {
      if let name = document["name"] as? String {
        emit(name, document)
      }
    }
  }

  database.viewNamed("schemes").setMapBlock("1") {
    (document, emit) in
    if document["type"] as? String == "Scheme" {
      if let name = document["name"] as? String {
        println("updating schemes View")
        emit(name, document)
      }
    }
  }

}

func printAll() {
  println("-- PRINTING ALL")
  database.viewNamed("all").setMapBlock("2") {
    (document, emit) in
    if let object:AnyObject = document["name"] {
      if let name = object as? String {
        emit(name, document)
      }
    }
  }
  let query = database.viewNamed("all").createQuery()
  var error:NSError?
  let result = query.run(&error)
  while let row = result?.nextRow() {
    println("\(row.key) / \(row.value)")
    println("Document: \(row.document)")
  }
  println("-- END ALL")
}


extension CBLView {
  // Just reorders the parameters to take advantage of Swift's trailing-block syntax.
  func setMapBlock(version: String, mapBlock: CBLMapBlock) -> Bool {
    return setMapBlock(mapBlock, version: version)
  }
}

//
//  CreateBlockPointTableViewController.swift
//  Quilt
//
//  Created by Caroline Begbie on 7/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import UIKit

class CreateBlockPointTableViewController: UITableViewController {

  var patches:[Patch] = []
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return patches.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return patches[section].points.count
    }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Patch \(section)"
  }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CreateBlockEditCell", forIndexPath: indexPath) as UITableViewCell
      
      let patch = patches[indexPath.section]
      let point = patch.points[indexPath.row]
      cell.textLabel?.text = "X: \(point.x), Y: \(point.y)"


        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      println(segue.destinationViewController)
      println(sender)
      let controller = segue.destinationViewController as CreateBlockPatchEditViewController
      controller.delegate = self
      let cell = sender as UITableViewCell
      if let indexPath = tableView.indexPathForCell(cell) {
        let patch = patches[indexPath.section]
        let point = patch.points[indexPath.row]
      
        controller.point = point
        controller.indexPath = indexPath
      }
      
    }

}

extension CreateBlockPointTableViewController: CreateBlockPatchEditViewControllerDelegate {
  func createBlockPatchEditViewControllerDidUpdate(point: CGPoint, indexPath:NSIndexPath) {
    println("did update")
    let patch = patches[indexPath.section]
    var patchPoint = patch.points[indexPath.row]
    patchPoint.x = point.x
    patchPoint.y = point.y
    patch.points[indexPath.row] = patchPoint
    self.tableView.reloadData()
    println(patch.points)
  }
}
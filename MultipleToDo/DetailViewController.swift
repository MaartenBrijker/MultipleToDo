//
//  DetailViewController.swift
//  MultipleToDo
//
//  Created by Maarten Brijker on 11/05/16.
//  Copyright © 2016 Maarten_Brijker. All rights reserved.
//

import UIKit
import SQLite

class DetailViewController: UIViewController {

    // Outlets for tableview and type field.
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addTextField: UITextField!
 
// MARK: - Basic app life cycle and table functions.

    var detailItem: AnyObject? {
        didSet {
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let detail = self.detailItem {
            self.title = detail.description
        }
        if detailItem != nil {
            ToDoManager.sharedInstance.displayToDoList(detailItem as! String)
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DetailViewController.loadList(_:)),name:"load", object: nil)
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // move me to todomanager later please
    func loadList(notification: NSNotification){
        self.title = ""
        tableView.reloadData()
    }

// MARK: - Adding to and setting up the database.
    
    // INSERT INTO "dontforgets" ("todo") VALUES ('buy groceries').
    @IBAction func addButton(sender: AnyObject) {
        let someToDo = addTextField.text!
        let checkie = false

        if detailItem != nil {
            ToDoManager.sharedInstance.addToDo(someToDo, MAINToDo: detailItem as! String, checkmark: checkie)
        }
        
        addTextField.text = ""
        tableView.reloadData()
        
        }
}

// MARK: - the UITableview.

extension DetailViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = ToDoManager.sharedInstance.stuff.count
        return numberOfRows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! CustomCell
        let values = Array(ToDoManager.sharedInstance.stuff)
        cell.toDoLabel.text = values[indexPath.row].1
        cell.selectionStyle = .None
        return cell
    }
    
    /// Delete rows.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        ToDoManager.sharedInstance.deleteToDo(indexPath.row, MAINToDo: detailItem as! String)
        
        tableView.reloadData()
        
    }
    
    // Checkmark rows
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell!.accessoryType == .Checkmark {
            cell!.accessoryType = .None
        } else {
            cell!.accessoryType = .Checkmark
        }
    }
}
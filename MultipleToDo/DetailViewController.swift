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

// MARK: - Basic app life cycle and table functions.
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addTextField: UITextField!
 
    var detailItem: AnyObject? {
        didSet {
        }
    }

    /// Setting the screentitle, display todo list, load data tableview.
    override func viewDidLoad() {
        self.title = "to 🎌 do"
        
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
    
    /// Needed for when screen is in landscape mode.
    func loadList(notification: NSNotification){
        self.title = ""
        tableView.reloadData()
    }

// MARK: - Adding to the database.
    
    // INSERT INTO "dontforgets" ("todo") VALUES ('buy groceries').
    @IBAction func addButton(sender: AnyObject) {
        let someToDo = addTextField.text!
        let checked = false

        if detailItem != nil {
            ToDoManager.sharedInstance.addToDo(someToDo, MAINToDo: detailItem as! String, checkmark: checked)
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
    
    /// Checkmark rows when tapped
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell!.accessoryType == .Checkmark {
            cell!.accessoryType = .None
        } else {
            cell!.accessoryType = .Checkmark
        }
    }
    
// MARK: - Deleting rows when swiped left.
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        ToDoManager.sharedInstance.deleteToDo(indexPath.row, MAINToDo: detailItem as! String)
        tableView.reloadData()
    }
}
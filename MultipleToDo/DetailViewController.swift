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
            //print(detailItem)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set title of ToDo list
        if let detail = self.detailItem {
            self.title = detail.description
        }
        ToDoManager.sharedInstance.setupDatabase()
        if detailItem != nil {
            ToDoManager.sharedInstance.displayToDoList(detailItem as! String)
        }
        tableView.reloadData()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DetailViewController.updateNotificationSentLabel), name: mySpecialNotificationKey, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateNotificationSentLabel() {
        //print("yaayyyyy")
    }
    
    
    

// MARK: - Adding to and setting up the database.
    
    // INSERT INTO "dontforgets" ("todo") VALUES ('buy groceries').
    @IBAction func addButton(sender: AnyObject) {
        
        let someToDo = addTextField.text!
        
        if detailItem != nil {
        ToDoManager.sharedInstance.addToDo(someToDo, MAINToDo: detailItem as! String)
        }
        
        // Clear textfield after submitting.
        addTextField.text = ""
        
        tableView.reloadData()
        
        NSNotificationCenter.defaultCenter().postNotificationName(mySpecialNotificationKey, object: self)
        
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
        
        ToDoManager.sharedInstance.deleteRowFromDatabase(indexPath.row, MAINToDo: detailItem as! String)
        
        tableView.reloadData()
        
    }
}






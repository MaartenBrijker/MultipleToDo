//
//  MasterViewController.swift
//  MultipleToDo
//
//  Created by Maarten Brijker on 11/05/16.
//  Copyright © 2016 Maarten_Brijker. All rights reserved.
//

import UIKit


// Globally define a "special notification key" constant that can be broadcast / tuned in to...
let mySpecialNotificationKey = "notify"


class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
//    var objects = [AnyObject]()

    var objects = ["groceries", "shopping", "sporting", "chilling"]


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(MasterViewController.showAlert(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
    }
    
    func updateNotificationSentLabel() {
        print("yaayyyyy")
    }
    
    
    

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showAlert(sender: AnyObject) {
        
        let alert = UIAlertController(title: "+ 🎌 +", message: "enter a new todo", preferredStyle: UIAlertControllerStyle.Alert)
        let loginAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.Default) { (_) in
            let nameTextField = alert.textFields![0] as UITextField
            self.insertNewObject(nameTextField.text!)
        }
        
        alert.addAction(loginAction)
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Enter text:"
        })
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func insertNewObject(name: String) {

        print("super!   ", name)

        
        if name != "" {
            objects.insert(name, atIndex: objects.count)
            print(objects)
            let indexPath = NSIndexPath(forRow: objects.count - 1, inSection: 0)
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    func login(input: String) {
        print(input)
    }

    
    
    
    
    
    
    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel!.text = objects[indexPath.row]
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            print(indexPath.row)
            
            let mainToDoName = objects[indexPath.row]
            

            objects.removeAtIndex(indexPath.row)

            
            ToDoManager.sharedInstance.deleteMainList(mainToDoName)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}


//
//  ToDoManager.swift
//  MultipleToDo
//
//  Created by Maarten Brijker on 11/05/16.
//  Copyright © 2016 Maarten_Brijker. All rights reserved.
//

import Foundation
import SQLite

class ToDoManager {
  
    

// MARK: - Setting up the database.
    
    static let sharedInstance = ToDoManager()
    
    private init() { }
    
    // List to hold "todo's" so tableview can display them.
    var stuff = [Int: String] ()
    
    // Variable to index which item to delete.
    var deleteId: Int?
    
    // Initiating the SQLite Database.
    var database: Connection?
    let dontforgets = Table("dontforgets")
    let id = Expression<Int>("id")
    let todo = Expression<String>("todo")

    func setupDatabase() {
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
        do {
            // If connection is set up, create table.
            database = try Connection("\(path)/db.sqlite3")
            createTable()
        }
        catch {
            print("Cannot connect to database: \(error)")
        }
    }
    
    func createTable(){
        do {
            try database!.run(dontforgets.create(ifNotExists: true) { t in   // CREATE TABLE: "dontforgets"
                t.column(id, primaryKey: .Autoincrement)                     // "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL.
                t.column(todo, unique: true)                                 // "todo" TEXT UNIQUE NOT NULL.
                })
        }
        catch {
            print("Failed to create table: \(error)")
        }
    }
    
    /// Loops over the database, puts 'id' and 'todo' in a dictionary so we can display and access values.
    func displayToDoList() {
        
        do {
            stuff = [:]
            for dontforget in try database!.prepare(dontforgets.select(id, todo)) {
                let todoKey = dontforget[id]
                let todoValue = dontforget[todo]
                stuff[todoKey] = todoValue
            }
        }
        catch {
            print("Failed to find todo: \(error)")
        }
    }

    
    
    
    
    
    
    
    
    
    
// MARK: - Adding a ToDo.
    
    func addToDo(someToDo: String) {
        
        do {
            if someToDo != "" {
                let insert = dontforgets.insert(todo <- someToDo)
                try database!.run(insert)
                
                // Update To Do list to be displayed.
                displayToDoList()
                
            }
        }
        catch {
            print("Error creating todo: \(error)")
        }
    }
    
    
    
    
    
    
    
    
// MARK: - Deleting row from the database.
    
    func deleteRowFromDatabase(index: Int) {
        
        // Get row id.
        let values = Array(ToDoManager.sharedInstance.stuff)
        deleteId = values[index].0
        print(values)
        print(index)
        print(deleteId)
        
        let toDelete = dontforgets.filter(id == deleteId!)
        
        do {
            // DELETE FROM "users" WHERE ("id" = 1)
            if try database!.run(toDelete.delete()) > 0 {
                print("deleted!")
            }
            else {
                print("Row not found")
            }
            displayToDoList()
        }
        catch {
            print("Delete failed: \(error)")
        }
    }
}
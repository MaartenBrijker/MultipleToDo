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
    
    // Nested dictionary to hold todo's, each with his key and mainToDo, so tableview can display them.
    var stuff = [Int: String] ()
    
    // Variable to index which item to delete.
    var deleteId: Int?
  
    // List to hold Main ToDo's.
    var MAINLISTS = [String]()
  
    // Initiating the SQLite Database.
    var database: Connection?
    let dontforgets = Table("dontforgets")
    let id = Expression<Int>("id")
    let todo = Expression<String>("todo")
    let mainToDo = Expression<String>("mainToDo")
    //let completed = Expression<Bool>("completed")
    
    let MAINS = Table("MAINS")
    let mastertodo = Expression<String>("mastertodo")
    
    func setupDatabase() {
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
        do {
            // If connection is set up, create table.
            database = try Connection("\(path)/db.sqlite3")
            createTable()
            createMAINTable()
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
                t.column(mainToDo, unique: false)                            // "mainToDo" TEXT NUNIQUE.
                //t.column(completed, defaultValue: false)                                          // "completed" BOOL.
                })
        }
        catch {
            print("Failed to create table: \(error)")
        }
    }
    
    /// Loops over the database, puts 'id' and 'todo' in a dictionary so we can display and access values.
    func displayToDoList(detailItem: String) {
        do {
            stuff = [:]
            for dontforget in try database!.prepare(dontforgets.select(id, todo, mainToDo)) {
                let todoKey = dontforget[id]
                let todoValue = dontforget[todo]
                let mainTodoValue = dontforget[mainToDo]
                //let completedValue = dontforget[completed]
                
                if mainTodoValue == detailItem {
                    stuff[todoKey] = todoValue
                }
            }
        }
        catch {
            print("Failed to find todo: \(error)")
        }
    }
    
    func createMAINTable(){
        do {
            try database!.run(MAINS.create(ifNotExists: true) { t in   // CREATE TABLE: "dontforgets"
                t.column(mastertodo, unique: true)                     // "todo" TEXT UNIQUE NOT NULL.
            })
        }
        catch {
            print("Failed to create table: \(error)")
        }
    }

    /// Puts all Main Todo's in a list.
    func displayMAIN() {
        do {
            MAINLISTS = []
            for somemain in try database!.prepare(MAINS.select(mastertodo)) {
                let mainTodoValue = somemain[mastertodo]
                MAINLISTS.insert(mainTodoValue, atIndex: MAINLISTS.count)
            }
        }
        catch {
            print("Failed to find todo: \(error)")
        }
    }
    
// MARK: - Adding a ToDo.
    
    /// Adds a ToDo to the database 'dontforgets'.
    func addToDo(someToDo: String, MAINToDo: String, checkmark: Bool) {
        do {
            if someToDo != "" {
                let insert = dontforgets.insert(todo <- someToDo, mainToDo <- MAINToDo)
                try database!.run(insert)
                
                // Update To Do list to be displayed.
                displayToDoList(MAINToDo)
            }
        }
        catch {
            print("Error creating todo: \(error)")
        }
    }
    
    /// Adds a Main ToDo to the database 'MAINS'.
    func addMainToDo(MAINToDo: String) {
        do {
            if MAINToDo != "" {
                let insert = MAINS.insert(mastertodo <- MAINToDo)
                try database!.run(insert)
                
                // Update To Do list to be displayed.
                displayMAIN()
            }
        }
        catch {
            print("Error creating todo: \(error)")
        }
    }

// MARK: - Deleting row from the database.
    
    /// Deletes a ToDo.
    func deleteToDo(index: Int, MAINToDo: String) {
        
        // Get row id.
        let values = Array(ToDoManager.sharedInstance.stuff)
        deleteId = values[index].0
        let toDelete = dontforgets.filter(id == deleteId!)
        do {
            // DELETE FROM "users" WHERE ("id" = 1)
            if try database!.run(toDelete.delete()) > 0 {
                print("deleted!")
            }
            else {
                print("Row not found")
            }
            displayToDoList(MAINToDo)
        }
        catch {
            print("Delete failed: \(error)")
        }
    }
    
    /// Deletes a Main ToDo from the table 'MAINS' plus al its children ToDo's from the table 'dontforgets'.
    func deleteMainList(mainToDoName: String) {
        
        // First delete all todo's in that specific list.
        let toDelete = dontforgets.filter(mainToDo == mainToDoName)
        do {
            if try database!.run(toDelete.delete()) > 0 {
                print("todo's in this MAIN deleted!")
            }
            else {
                print("Row not found")
            }            
        }
        catch {
            print("Delete failed: \(error)")
        }

        // Then delete that main todo list.
        let mainToDelete = MAINS.filter(mastertodo == mainToDoName)
        do {
            if try database!.run(mainToDelete.delete()) > 0 {
                print("MAIN deleted!")
            }
            else {
                print("Row not found")
            }
        }
        catch {
            print("Delete failed: \(error)")
        }
    }
}
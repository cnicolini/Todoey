//
//  CategoryViewControllerTableViewController.swift
//  Todoey
//
//  Created by cn on 2/14/18.
//  Copyright © 2018 nicolinihome. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewControllerTableViewController: SwipeTableViewController {


    var realm: Realm!
    
    var categories: Results<Category>?
    
    // Used to print the location of the plist file
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        print(dataFilePath ?? "No data file path")

        // Updating Realm Schema from version 0 to 1
        updateSchema()
        
        realm = try! Realm()
        
        // Location of the Realm database
        print(Realm.Configuration.defaultConfiguration.fileURL ?? "")
        
        loadCategories()
        tableView.rowHeight = 80.0
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        let category = categories?[indexPath.row]
        
        cell.textLabel?.text = category?.name ?? "No Categories Added Yet"
        
        return cell
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var categoryTextField = UITextField()
        
        let alert = UIAlertController.init(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (category) in
            
            print("Success entering new category \(categoryTextField.text!)")
            
            let newCategory = Category()
            newCategory.name = categoryTextField.text!
            
            self.save(category: newCategory)
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add New Category"
            
            categoryTextField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    override func deleteCell(at indexPath: IndexPath) {
        if let category = categories?[indexPath.row] {
            delete(category: category)
        }
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    //MARK: - Data Manipulation Methods
    func loadCategories() {
        categories = realm.objects(Category.self)

        tableView.reloadData()
    }
    
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        }
        catch {
            print("Error saving category \(error)")
        }
        
        tableView.reloadData()
    }
    
    func delete(category: Category) {
        do {
            try realm.write {
                realm.delete(category.items)
                realm.delete(category)
            }
        }
        catch {
            print("Error deleting category \(error)")
        }
    }
    
    //MARK: - Data Definigion
    func updateSchema() {
        
        let config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    migration.enumerateObjects(ofType: Item.className(), { (oldItem, newItem) in
                        newItem?["dateCreated"] = Date()
                    })
                }
                
        }
        )
        
        Realm.Configuration.defaultConfiguration = config
        
    }
    
}


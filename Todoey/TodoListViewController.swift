//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Ben Wong on 2019-06-29.
//  Copyright © 2019 Ben Wong. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
  
  private var todoArray = [
    Todo(named: "Find Mike"),
    Todo(named: "Buy Eggos"),
    Todo(named: "Destroy Demogorgon")
  ]
  let defaults = UserDefaults.standard
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let todoList = defaults.value(forKey: "TodoList") as? [Todo] {
      todoArray = todoList
    }
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
  }
  
  // MARK: - Table View Configuration
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return todoArray.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
    let todo = todoArray[indexPath.row]
    cell.textLabel?.text = todo.title
    cell.accessoryType = todo.done ? .checkmark : .none
    return cell
  }
  
  // MARK: - Table View Selection
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let todo = todoArray[indexPath.row]
    
    toggleCompleted(for: todo)
    tableView.reloadData()
    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
      tableView.deselectRow(at: indexPath, animated: true)
    }
  }
  
  private func toggleCompleted(for todo: Todo) {
    todo.done = !todo.done
  }

  // MARK: - Add Todo Item
  @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
    let alert = createAddTodoAlert()
    present(alert, animated: true, completion: nil)
  }
  
  private func createAddTodoAlert() -> UIAlertController {
    let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
    var textField = UITextField()
    
    let action = UIAlertAction(title: "Add Item", style: .default) { _ in
      guard let todo = textField.text else { return }
      self.addTodo(todo)
    }
    
    alert.addAction(action)
    alert.addTextField { alertTextField in
      alertTextField.placeholder = "New Todo"
      textField = alertTextField
    }
    
    return alert
  }
  
  private func addTodo(_ title: String) {
    todoArray.append(Todo(named: title))
    defaults.setValue(todoArray, forKey: "TodoList")
    tableView.reloadData()
  }
  /*
  // Override to support conditional editing of the table view.
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
  }
  */

  /*
  // Override to support editing the table view.
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
        // Delete the row from the data source
        tableView.deleteRows(at: [indexPath], with: .fade)
    } else if editingStyle == .insert {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
  }
  */

  /*
  // Override to support rearranging the table view.
  override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

  }
  */

  /*
  // Override to support conditional rearranging of the table view.
  override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
  }
  */

  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destination.
    // Pass the selected object to the new view controller.
  }
  */

}

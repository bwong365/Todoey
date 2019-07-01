//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Ben Wong on 2019-06-29.
//  Copyright © 2019 Ben Wong. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
  
  private var todoArray = [Todo]()
  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

  override func viewDidLoad() {
    super.viewDidLoad()
    loadTodoData()
    
  }
  
  @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
    let alert = createAddTodoAlert()
    present(alert, animated: true, completion: nil)
  }
}

// MARK: - Table View Configuration
extension TodoListViewController {
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

    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
      tableView.deselectRow(at: indexPath, animated: true)
    }
  }
  
  private func toggleCompleted(for todo: Todo) {
    todo.done = !todo.done
    handleDataChange()
  }
}

// MARK: - Add Todo Item
extension TodoListViewController {
  private func createAddTodoAlert() -> UIAlertController {
    let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
    var textField = UITextField()
    
    let addAction = UIAlertAction(title: "Add Item", style: .default) { _ in
      guard let todoTitle = textField.text else { return }
      self.addTodo(withTitle: todoTitle)
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
    
    alert.addAction(cancelAction)
    alert.addAction(addAction)

    alert.addTextField { alertTextField in
      alertTextField.placeholder = "New Todo"
      textField = alertTextField
    }
    
    return alert
  }
  
  private func addTodo(withTitle title: String) {
    let todo = Todo(context: context)
    todo.title = title
    todo.done = false
    todoArray.append(todo)
    handleDataChange()
  }
}

// MARK: - Persist Data
extension TodoListViewController {
  private func handleDataChange() {
    saveTodoData()
    tableView.reloadData()
  }
  
  private func saveTodoData() {
    do {
      try context.save()
    } catch {
      print("Error saving context, \(error)")
    }
  }
  
  private func loadTodoData() {
    let request: NSFetchRequest = Todo.fetchRequest()
    
    do {
      todoArray = try context.fetch(request)
    } catch {
      print("Error loading from context , \(error)")
    }
  }
}

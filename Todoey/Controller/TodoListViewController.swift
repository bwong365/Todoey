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
  
  var selectedCategory: Category? {
    didSet {
      loadTodoData()
    }
  }
  private var todoArray = [Todo]()
  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  
  @IBOutlet weak var searchBar: UISearchBar!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureRefreshControl()
    addTapGesture()
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
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    toggleCompleted(for: indexPath)
  }
  
  internal override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      promptDelete(for: indexPath)
    }
  }
}

// MARK: - Table View Methods
extension TodoListViewController {
  private func toggleCompleted(for indexPath: IndexPath) {
    let todo = todoArray[indexPath.row]
    todo.done = !todo.done
    saveTodoData()
    tableView.reloadData()
    
    animateDeselection(for: indexPath)
  }
  
  private func animateDeselection(for indexPath: IndexPath) {
    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
      self.tableView.deselectRow(at: indexPath, animated: true)
    }
  }
  
  private func promptDelete(for indexPath: IndexPath) {
    let deleteAlert = createDeleteTodoAlert(for: indexPath)
    present(deleteAlert, animated: true, completion: nil)
  }
}

// MARK: - CRUD
extension TodoListViewController {
  private func createAddTodoAlert() -> UIAlertController {
    let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
    var textField = UITextField()
    
    let addAction = UIAlertAction(title: "Add Item", style: .default) { _ in
      guard let todoTitle = textField.text, textField.text!.count > 0 else { return }
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
    todo.parentCategory = selectedCategory
    todoArray.append(todo)
    saveTodoData()
    tableView.reloadData()
  }
  
  private func createDeleteTodoAlert(for indexPath: IndexPath) -> UIAlertController {
    let deleteAlert = UIAlertController(title: "Would you like to delete", message: "\(todoArray[indexPath.row].title ?? "this todo")?", preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
      self.deleteTodo(from: indexPath)
    }
    deleteAlert.addAction(cancelAction)
    deleteAlert.addAction(deleteAction)
    return deleteAlert
  }
  
  private func deleteTodo(from indexPath: IndexPath) {
    context.delete(todoArray[indexPath.row])
    todoArray.remove(at: indexPath.row)
    tableView.deleteRows(at: [indexPath], with: .left)
    saveTodoData()
  }
}

// MARK: - Persist Data
extension TodoListViewController {
  private func saveTodoData() {
    do {
      try context.save()
    } catch {
      print("Error saving context, \(error)")
    }
  }
  
  private func loadTodoData(with request: NSFetchRequest<Todo> = Todo.fetchRequest(), completion: (() -> Void)? = nil) {
    defer {
      completion?()
    }
    
    let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
    request.predicate = addPredicate(to: request, and: categoryPredicate)
    
    do {
      todoArray = try context.fetch(request)
    } catch {
      print("Error loading from context , \(error)")
    }
    self.tableView.reloadData()
  }
  
  private func addPredicate(to request: NSFetchRequest<Todo>, and predicate: NSPredicate) -> NSCompoundPredicate {
    var subPredicates = [NSPredicate]()
    subPredicates.append(predicate)
    if let oldPredicate = request.predicate {
      subPredicates.append(oldPredicate)
    }
    return NSCompoundPredicate(type: .and, subpredicates: subPredicates)
  }
}

// MARK: - Pulldown Refresh
extension TodoListViewController {
  private func configureRefreshControl() {
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(refreshTodos), for: .valueChanged)
  }
  
  @objc private func refreshTodos() {
    setTableAlpha(to: 0.5)
    loadTodoData() {
      self.setTableAlpha(to: 1)
      self.refreshControl?.endRefreshing()
    }
  }
  
  private func setTableAlpha(to alpha: CGFloat) {
    UIView.animate(withDuration: 0.3) {
      self.tableView.alpha = alpha
    }
  }
}

// MARK: - Search Bar
extension TodoListViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    let request: NSFetchRequest<Todo> = Todo.fetchRequest()
    request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
    request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
    loadTodoData(with: request)
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText.count == 0 {
      loadTodoData()
    }
  }
  
  // Called in viewDidLoad()
  func addTapGesture() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
    tapGesture.cancelsTouchesInView = false
    view.addGestureRecognizer(tapGesture)
  }
  
  @objc private func viewTapped() {
    DispatchQueue.main.async {
      self.searchBar.resignFirstResponder()
    }
  }
}

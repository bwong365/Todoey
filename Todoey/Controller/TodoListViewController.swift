//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Ben Wong on 2019-06-29.
//  Copyright © 2019 Ben Wong. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController {
  let realm = try! Realm()
  private var todos: List<Todo>?

  var selectedCategory: Category? {
    didSet {
      loadTodoData()
    }
  }
  
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
    let count = todos?.count
    return (count ?? 0 > 0) ? count! : 1
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
    
    if (todos?.count ?? 0) > 0, let todo = todos?[indexPath.row] {
      cell.textLabel?.text = todo.title
      cell.accessoryType = todo.done ? .checkmark : .none
      cell.textLabel?.textColor = UIColor.black
    } else {
      cell.textLabel?.text = "No Todos Added"
      cell.textLabel?.textColor = UIColor.gray
    }
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    defer { animateDeselection(for: indexPath) }
    guard todos!.count > 0 else { return }
    toggleCompleted(for: indexPath)
  }
  
  internal override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
//      promptDelete(for: indexPath)
    }
  }
}

// MARK: - Table View Methods
extension TodoListViewController {
  private func toggleCompleted(for indexPath: IndexPath) {
    guard let todo = todos?[indexPath.row] else { return }
    writeData {
      todo.done = !todo.done
    }
    tableView.reloadData()
  }
  
  private func animateDeselection(for indexPath: IndexPath) {
    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
      self.tableView.deselectRow(at: indexPath, animated: true)
    }
  }
  
//  private func promptDelete(for indexPath: IndexPath) {
//    let deleteAlert = createDeleteTodoAlert(for: indexPath)
//    present(deleteAlert, animated: true, completion: nil)
//  }
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
    guard let category = selectedCategory else { return }
    writeData {
      let todo = Todo()
      todo.title = title
      category.todos.append(todo)
    }
    
    tableView.reloadData()
  }
  
//  private func createDeleteTodoAlert(for indexPath: IndexPath) -> UIAlertController {
//    let deleteAlert = UIAlertController(title: "Would you like to delete", message: "\(todoArray[indexPath.row].title ?? "this todo")?", preferredStyle: .alert)
//    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//    let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
//      self.deleteTodo(from: indexPath)
//    }
//    deleteAlert.addAction(cancelAction)
//    deleteAlert.addAction(deleteAction)
//    return deleteAlert
//  }
//
//  private func deleteTodo(from indexPath: IndexPath) {
//    context.delete(todoArray[indexPath.row])
//    todoArray.remove(at: indexPath.row)
//    tableView.deleteRows(at: [indexPath], with: .left)
//    saveTodoData()
//  }
}

// MARK: - Persist Data
extension TodoListViewController {
  private func loadTodoData(completion: (() -> Void)? = nil) {
    defer {
      completion?()
    }
    todos = selectedCategory?.todos // .sorted(byKeyPath: "title", ascending: true)
    self.tableView.reloadData()
  }
  
  private func writeData(_ code: () -> Void) {
    do {
      try realm.write {
        code()
      }
    } catch {
      print("There was an error writing to realm, \(error)")
    }
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
//  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//    let request: NSFetchRequest<Todo> = Todo.fetchRequest()
//    request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//    request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//    loadTodoData(with: request)
//  }
//
//  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//    if searchText.count == 0 {
//      loadTodoData()
//    }
//  }
//
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

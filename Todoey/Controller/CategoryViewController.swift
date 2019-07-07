//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Ben Wong on 2019-07-01.
//  Copyright © 2019 Ben Wong. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: SwipeTableViewController {
  
  let realm = try! Realm()
  var categories: Results<Category>?
  
  override func viewDidLoad() {
    super.viewDidLoad()
//    print(realm.configuration.fileURL)
    loadCategoryData()
    setupRefresh()
  }
  
  @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
    promptAddCategory()
  }
  
  override func deleteActionSwiped(at indexPath: IndexPath) {
    promptDeleteCategory(for: indexPath)
  }
}

// MARK: - Configure TableView
extension CategoryViewController {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let count = categories?.count ?? 1
    return count > 0 ? count : 1
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = super.tableView(tableView, cellForRowAt: indexPath)
    
    if categories == nil || categories?.count == 0 {
      cell.textLabel?.text = "No Categories Added"
      cell.textLabel?.textColor = UIColor.gray
    } else {
      cell.textLabel?.text = categories?[indexPath.row].name
      cell.textLabel?.textColor = UIColor.black
    }
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    defer {
      animateDeselection(for: indexPath)
    }
    guard categories?.count ?? 0 > 0 else { return }
    performSegue(withIdentifier: "gotoTodoList", sender: self)
  }
  
  private func animateDeselection(for indexPath: IndexPath) {
    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
      self.tableView.deselectRow(at: indexPath, animated: true)
    }
  }
}

// MARK: - Refresh Control
extension CategoryViewController {
  private func setupRefresh() {
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(refreshCategoryData), for: .valueChanged)
  }
  
  @objc private func refreshCategoryData() {
    setTableAlpha(to: 0.5)
    loadCategoryData() {
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

// MARK: - CRUD
extension CategoryViewController {
  private func promptAddCategory() {
    let alert = createAddCategoryAlert()
    present(alert, animated: true, completion: nil)
  }
  
  private func createAddCategoryAlert() -> UIAlertController {
    let addAlert = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
    var textField = UITextField()
    
    let addAction = UIAlertAction(title: "Add", style: .default) { _ in
      guard let categoryTitle = textField.text, textField.text!.count > 0 else { return }
      self.addCategory(named: categoryTitle)
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
    
    addAlert.addAction(addAction)
    addAlert.addAction(cancelAction)
    addAlert.addTextField { alertTextField in
      alertTextField.placeholder = "Category Name"
      textField = alertTextField
    }
    return addAlert
  }
  
  private func addCategory(named name: String) {
    let category = Category()
    category.name = name
    save(category: category)
    tableView.reloadData()
  }

  
  private func promptDeleteCategory(for indexPath: IndexPath) {
    let alert = createDeleteCategoryAlert(for: indexPath)
    present(alert, animated: true, completion: nil)
  }

  private func createDeleteCategoryAlert(for indexPath: IndexPath) -> UIAlertController {
    let deleteAlert = UIAlertController(title: "Delete category:", message: "\(categories?[indexPath.row].name ?? "this category")?", preferredStyle: .alert)
    let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
      self.deleteCategory(for: indexPath)
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    deleteAlert.addAction(deleteAction)
    deleteAlert.addAction(cancelAction)
    return deleteAlert
  }

  private func deleteCategory(for indexPath: IndexPath) {
    guard let category = categories?[indexPath.row] else { return }
    writeData {
      realm.delete(category)
    }
    tableView.deleteRows(at: [indexPath], with: .left)
  }
}

// MARK: - Persist Data
extension CategoryViewController {
  private func save(category: Category) {
    writeData {
      realm.add(category)
    }
  }
  
  private func loadCategoryData(completion: (() -> Void)? = nil) {
    defer {
      completion?()
    }
    categories = realm.objects(Category.self)
    tableView.reloadData()
  }
  
  /// Writes data to the realm declared in instance variables
  ///
  /// Uses the realm.write function, executing a closure within the do-block.
  /// Prints an error on failure. Use this method to make your changes persist.
  /// - important: A realm must be declared within the class variables.
  /// - parameter code: Closure to execute inside the realm.write do-block
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

extension CategoryViewController {
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "gotoTodoList":
      guard let row = tableView.indexPathForSelectedRow?.row else { return }
      let destinationVC = segue.destination as! TodoListViewController
      destinationVC.selectedCategory = categories?[row]
    default:
      return
    }
  }
}

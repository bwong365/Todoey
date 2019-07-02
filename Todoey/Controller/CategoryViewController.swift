//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Ben Wong on 2019-07-01.
//  Copyright © 2019 Ben Wong. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
  
  var categoryArray = [Category]()
  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loadCategoryData()
    setupRefresh()
  }
  
  @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
    promptAddCategory()
  }
}

extension CategoryViewController {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return categoryArray.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
    cell.textLabel?.text = categoryArray[indexPath.row].name
    return cell
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
    let category = Category(context: context)
    category.name = name
    categoryArray.append(category)
    saveCategoryData()
    tableView.reloadData()
  }
}

// MARK: - Persist Data
extension CategoryViewController {
  private func saveCategoryData() {
    do {
      try context.save()
    } catch {
      print("There was an error saving to context, \(error)")
    }
  }
  
  private func loadCategoryData(request: NSFetchRequest<Category> = Category.fetchRequest(),
                                completion: (() -> Void)? = nil) {
    defer {
      completion?()
    }
    
    do {
      categoryArray = try context.fetch(request)
    } catch {
      print("There was an error loading from context, \(error)")
    }
    tableView.reloadData()
  }
}

//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by Ben Wong on 2019-07-06.
//  Copyright © 2019 Ben Wong. All rights reserved.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {
  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath,
                 for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
    guard orientation == .right else { return nil}
    let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (_, indexPath) in
      self.deleteActionSwiped(at: indexPath)
    }
    deleteAction.image = UIImage(named: "delete-icon")
    return [deleteAction]
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func deleteActionSwiped(at indexPath: IndexPath) {
    // delete actions
  }
}

// MARK - TableView Datasource Methods
extension SwipeTableViewController {
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
    cell.delegate = self
    return cell
  }
}

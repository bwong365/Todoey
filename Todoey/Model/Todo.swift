//
//  Todo.swift
//  Todoey
//
//  Created by Ben Wong on 2019-07-01.
//  Copyright © 2019 Ben Wong. All rights reserved.
//

import Foundation
import RealmSwift

class Todo: Object {
  @objc dynamic var title = ""
  @objc dynamic var done = false
  let parentCategory = LinkingObjects(fromType: Category.self, property: "todos")
}

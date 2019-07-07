//
//  Category.swift
//  Todoey
//
//  Created by Ben Wong on 2019-07-01.
//  Copyright © 2019 Ben Wong. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
  @objc dynamic var name = ""
  @objc dynamic var backgroundColor = ""
  let todos = List<Todo>()
}

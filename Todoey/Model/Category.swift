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
  let todos = List<Todo>()
}

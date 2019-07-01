//
//  Todo.swift
//  Todoey
//
//  Created by Ben Wong on 2019-06-30.
//  Copyright © 2019 Ben Wong. All rights reserved.
//

import Foundation

class Todo {
  var title: String
  var done: Bool
  
  init(named title: String) {
    self.title = title
    done = false
  }
}

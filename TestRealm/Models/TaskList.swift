//
//  TaskList.swift
//  TestRealm
//
//  Created by Alexey Turulin on 8/8/23.
//

import Foundation

struct TaskList {
    var title = ""
    var data = Date()
    var tasks: [Task] = []
}

struct Task {
    var title = ""
    var note = ""
    var date = Date()
    var isComplete = false
}

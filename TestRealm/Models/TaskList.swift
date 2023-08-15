//
//  TaskList.swift
//  TestRealm
//
//  Created by Alexey Turulin on 8/8/23.
//

import Foundation
import RealmSwift

final class TaskList: Object {
    @Persisted var title = ""
    @Persisted var data = Date()
    @Persisted var tasks = List<Task>()
}

final class Task: Object {
    @Persisted var title = ""
    @Persisted var note = ""
    @Persisted var date = Date()
    @Persisted var isComplete = false
}

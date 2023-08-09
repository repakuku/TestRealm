//
//  StorageManager.swift
//  TestRealm
//
//  Created by Alexey Turulin on 8/8/23.
//

import Foundation

final class StorageManager {
    static let shared = StorageManager()
    
    var taskLists: [TaskList] = []
    
    private let key = "TaskLists"
    
    private init() {}
    
    func fetchData() {
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        guard let list = try? JSONDecoder().decode([TaskList].self, from: data) else { return }
        taskLists = list
    }
    
    func save() {
        guard let data = try? JSONEncoder().encode(taskLists) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}

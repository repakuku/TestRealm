//
//  StorageManager.swift
//  TestRealm
//
//  Created by Alexey Turulin on 8/8/23.
//

import Foundation

final class StorageManager {
    static let shared = StorageManager()
    
    private let userDefaults = UserDefaults.standard
    private let key = "TaskLists"
    
    private init() {}
    
    func fetchData() -> [TaskList] {
        guard let data = userDefaults.data(forKey: key) else { return [] }
        guard let taskList = try? JSONDecoder().decode([TaskList].self, from: data) else { return [] }
        return taskList
    }
    
    func save(_ taskList: TaskList) {
        var taskLists = fetchData()
        taskLists.append(taskList)
        guard let data = try? JSONEncoder().encode(taskLists) else { return }
        userDefaults.set(data, forKey: key)
    }
    
    func deleteTaskList(at index: Int) {
        var taskLists = fetchData()
        taskLists.remove(at: index)
        guard let data = try? JSONEncoder().encode(taskLists) else { return }
        userDefaults.set(data, forKey: key)
    }
}

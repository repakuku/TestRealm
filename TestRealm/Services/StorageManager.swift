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
    
    func save(_ taskLists: [TaskList]) {
        guard let data = try? JSONEncoder().encode(taskLists) else { return }
        userDefaults.set(data, forKey: key)
    }
    
    func save(_ taskList: TaskList) {
        var taskLists = fetchData()
        taskLists.append(taskList)
        save(taskLists)
    }
    
    func save(_ task: Task, toTaskListAt index: Int) {
        var taskLists = fetchData()
        taskLists[index].tasks.append(task)
        save(taskLists)
    }
    
    func deleteTaskList(at index: Int) {
        var taskLists = fetchData()
        taskLists.remove(at: index)
        save(taskLists)
    }
    
    func deleteTask(at taskIndex: Int, inTaskListAt taskListIndex: Int) {
        var taskLists = fetchData()
        taskLists[taskListIndex].tasks.remove(at: taskIndex)
        save(taskLists)
    }
}

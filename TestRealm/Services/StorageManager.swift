//
//  StorageManager.swift
//  TestRealm
//
//  Created by Alexey Turulin on 8/8/23.
//

import Foundation

final class StorageManager {
    static let shared = StorageManager()
    
    private let key = "TaskLists"
    
    private init() {}
    
    func fetchData() -> [TaskList] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        guard let taskList = try? JSONDecoder().decode([TaskList].self, from: data) else { return [] }
        return taskList
    }
    
    func save(_ taskLists: [TaskList]) {
        guard let data = try? JSONEncoder().encode(taskLists) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

}

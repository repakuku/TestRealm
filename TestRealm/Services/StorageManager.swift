//
//  StorageManager.swift
//  TestRealm
//
//  Created by Alexey Turulin on 8/8/23.
//

import Foundation
import RealmSwift

final class StorageManager {
    static let shared = StorageManager()
    
    let realm = try! Realm()
    
    private let userDefaults = UserDefaults.standard
    private let key = "TaskLists"
    
    private init() {}
    
    func fetchData() -> [TaskList] {
        return []
    }
    
    // MARK: - Task List
    func save(_ taskLists: [TaskList]) {
        try! realm.write {
            realm.add(taskLists)
        }
    }
        
    // MARK: - Task

}

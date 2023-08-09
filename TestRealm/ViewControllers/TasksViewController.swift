//
//  TasksViewController.swift
//  TestRealm
//
//  Created by Alexey Turulin on 8/7/23.
//

import UIKit

class TasksViewController: UITableViewController {
    
    // MARK: - Properties
    var taskListIndexPath: IndexPath!
    
    // MARK: - Private Properties
    private let cellID = "tasks"
    private let storageManager = StorageManager.shared
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        setupNavigationBar()
    }

    // MARK: - Private Methods
    @objc private func addTask() {
        let taskList = storageManager.taskLists[taskListIndexPath.row]
        let number = taskList.tasks.count
        let task = Task(title: "Task \(number)", note: "Note", date: Date(), isComplete: false)
        storageManager.taskLists[taskListIndexPath.row].tasks.append(task)
        storageManager.save()
        tableView.reloadData()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        let taskList = storageManager.taskLists[taskListIndexPath.row]
        title = taskList.title
        
        let editButton = editButtonItem
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTask)
        )
        
        navigationItem.rightBarButtonItems = [addButton, editButton]
    }
}

// MARK: - UITableViewDataSource
extension TasksViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let taskList = storageManager.taskLists[taskListIndexPath.row]
        return taskList.tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        var content = cell.defaultContentConfiguration()
        let taskList = storageManager.taskLists[taskListIndexPath.row]
        let task = taskList.tasks[indexPath.row]
        content.text = task.title
        content.secondaryText = task.note
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TasksViewController {
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete") { [unowned self] _, _, _ in
                storageManager.taskLists[indexPath.row].tasks.remove(at: indexPath.row)
                storageManager.save()
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        
        let editAction = UIContextualAction(
            style: .normal,
            title: "Edit") { _, _, isDone in
                
                isDone(true)
            }
        
        let doneAction = UIContextualAction(
            style: .normal,
            title: "Done") { _, _, isDone in
                isDone(true)
            }
        
        editAction.backgroundColor = .systemOrange
        doneAction.backgroundColor = .systemGreen
        
        return UISwipeActionsConfiguration(actions: [doneAction, editAction ,deleteAction])
    }
}

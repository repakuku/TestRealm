//
//  TasksViewController.swift
//  TestRealm
//
//  Created by Alexey Turulin on 8/7/23.
//

import UIKit

class TasksViewController: UITableViewController {
    
    // MARK: - Properties
    unowned var delegate: TasksViewControllerDelegate!
    
    var taskList: TaskList!
    var taskListindex: Int!
    
    // MARK: - Private Properties
    private let cellID = "tasks"
    private let storageManager = StorageManager.shared
    
    private var completedTasks: [Task] = []
    private var currentTasks: [Task] = []
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        setupNavigationBar()
        
        updateTasks()
    }

    // MARK: - Private Methods
    @objc private func addTask() {
        let number = taskList.tasks.count
        let task = Task(title: "Task \(number)", note: "Note", date: Date(), isComplete: false)
        taskList.tasks.append(task)
        delegate.update(taskList, at: taskListindex)
        updateTasks()
        tableView.reloadData()
    }
    
    private func updateTasks() {
        currentTasks = taskList.tasks.filter { !$0.isComplete }
        completedTasks = taskList.tasks.filter { $0.isComplete }
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
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
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "CURRENT TASKS" : "COMPLETED TASKS"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? currentTasks.count : completedTasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        var content = cell.defaultContentConfiguration()
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
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
            title: "Delete") { [unowned self]  _, _, _ in
                let deletedTask = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
                guard let index = taskList.tasks.firstIndex(of: deletedTask) else { return }
                taskList.tasks.remove(at: index)
                delegate.update(taskList, at: taskListindex)
                updateTasks()
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

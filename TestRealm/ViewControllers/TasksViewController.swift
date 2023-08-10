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
    var taskListIndex: Int!
    
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
        
        currentTasks = taskList.tasks.filter { !$0.isComplete }
        completedTasks = taskList.tasks.filter { $0.isComplete }
    }

    // MARK: - Private Methods
    @objc private func addTask() {
        let title = "Task \(taskList.tasks.count + 1)"
        let task = Task(
            title: title,
            note: "Task description",
            date: Date(),
            isComplete: false
        )
        taskList.tasks.append(task)
        currentTasks.append(task)
        delegate.add(task, toTaskListAt: taskListIndex)
        tableView.reloadData()
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
        guard let taskIndex = taskList.tasks.firstIndex(of: indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]) else { return UISwipeActionsConfiguration() }
        
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete") { [unowned self]  _, _, _ in
                if indexPath.section == 0 {
                    currentTasks.remove(at: indexPath.row)
                } else {
                    completedTasks.remove(at: indexPath.row)
                }
                taskList.tasks.remove(at: taskIndex)
                delegate.deleteTask(at: taskIndex, inTaskListAt: taskListIndex)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        
        let editAction = UIContextualAction(
            style: .normal,
            title: "Edit") { _, _, isDone in
                
                isDone(true)
            }
        
        let doneButtonTitle = indexPath.section == 0 ? "Done" : "Undone"
        let doneAction = UIContextualAction(
            style: .normal,
            title: doneButtonTitle) { [unowned self] _, _, isDone in
                if indexPath.section == 0 {
                    currentTasks[indexPath.row].isComplete.toggle()
                    let removedTask = currentTasks.remove(at: indexPath.row)
                    completedTasks.append(removedTask)
                } else {
                    completedTasks[indexPath.row].isComplete.toggle()
                    let removedTask = completedTasks.remove(at: indexPath.row)
                    currentTasks.append(removedTask)
                }
                taskList.tasks[taskIndex].isComplete.toggle()
                delegate.doneTask(at: taskIndex, inTaskListAt: taskListIndex)
                
                tableView.reloadData()
            }
        
        editAction.backgroundColor = .systemOrange
        doneAction.backgroundColor = .systemGreen
        
        return UISwipeActionsConfiguration(actions: [doneAction, deleteAction])
//        return UISwipeActionsConfiguration(actions: [doneAction, editAction ,deleteAction])
    }
}

//
//  TasksViewController.swift
//  TestRealm
//
//  Created by Alexey Turulin on 8/7/23.
//

import UIKit

final class TasksViewController: UITableViewController {
    
    // MARK: - Properties
    var taskList: TaskList!
    
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
        showAlert()
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

// MARK: - Task
extension TasksViewController {
    private func saveTask() {
        //
        tableView.reloadData()
    }
    
    private func showAlert(with task: Task? = nil, completion: ((String, String) -> Void)? = nil) {
        let alertBuilder = AlertControllerBuilder(
            title: task != nil ? "Edit Task" : "New Task",
            message: "What do you want to do?"
        )
        
        alertBuilder
            .setTextFields(
                title: task?.title,
                note: task?.note
            )
            .addAction( title: task != nil ? "Edit Task" : "Save Task", style: .default) { [weak self] title, note in
                if let task, let completion {
                    //
                    return
                }
                self?.saveTask()
            }
            .addAction(title: "Cancel", style: .destructive)
        
        let alertController = alertBuilder.build()
        present(alertController, animated: true)
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
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        
        showAlert(with: task) { [unowned self] title, note in
            if indexPath.section == 0 {
                currentTasks[indexPath.row].title = title
                currentTasks[indexPath.row].note = note
            } else {
                completedTasks[indexPath.row].title = title
                completedTasks[indexPath.row].note = note
            }
            
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete") { [unowned self]  _, _, _ in
                //
            }
        
        let editAction = UIContextualAction(
            style: .normal,
            title: "Edit") { [unowned self] _, _, isDone in
                //
                isDone(true)
            }
        
        let doneButtonTitle = indexPath.section == 0 ? "Done" : "Undone"
        let doneAction = UIContextualAction(
            style: .normal,
            title: doneButtonTitle) { [unowned self] _, _, isDone in
                //
                isDone(true)
            }
        
        editAction.backgroundColor = .systemOrange
        doneAction.backgroundColor = .systemGreen
        
        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }
}

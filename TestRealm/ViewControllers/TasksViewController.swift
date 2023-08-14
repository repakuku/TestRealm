//
//  TasksViewController.swift
//  TestRealm
//
//  Created by Alexey Turulin on 8/7/23.
//

import UIKit

final class TasksViewController: UITableViewController {
    
    // MARK: - Properties
    unowned var delegate: TasksViewControllerDelegate!
    var taskListIndex: Int!
    
    // MARK: - Private Properties
    private let cellID = "tasks"
    private let storageManager = StorageManager.shared
    private var taskLists: [TaskList]!
    private var completedTasks: [Task] = []
    private var currentTasks: [Task] = []
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskLists = storageManager.fetchData()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        setupNavigationBar()
        
        currentTasks = taskLists[taskListIndex].tasks.filter { !$0.isComplete }
        completedTasks = taskLists[taskListIndex].tasks.filter { $0.isComplete }
    }

    // MARK: - Private Methods
    @objc private func addTask() {
        showAlert()
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = taskLists[taskListIndex].title
        
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
    private func saveTask(withTitle title: String, andNote note: String?) {
        let task = Task(title: title, note: note ?? "", date: Date(), isComplete: false)
        taskLists[taskListIndex].tasks.append(task)
        currentTasks.append(task)
        delegate.add(task, toTaskListAt: taskListIndex)
        tableView.reloadData()
    }
    
    private func showAlert(withTaskAt index: Int? = nil, completion: ((String, String) -> Void)? = nil) {
        let alertBuilder = AlertControllerBuilder(
            title: index != nil ? "Edit Task" : "New Task",
            message: "What do you want to do?"
        )
        
        alertBuilder
            .setTextFields(
                title: index != nil ? taskLists[taskListIndex].tasks[index ?? 0].title : "",
                note: index != nil ? taskLists[taskListIndex].tasks[index ?? 0].note : ""
            )
            .addAction(title: index != nil ? "Edit Task" : "Save Task", style: .default) { [weak self] title, note in
                if let index, let taskListIndex = self?.taskListIndex, let completion {
                    self?.delegate.editTask(
                        at: index,
                        inTaskListAt: taskListIndex,
                        withTitle: title,
                        andNote: note)
                    completion(title, note)
                    return
                }
                self?.saveTask(withTitle: title, andNote: note)
            }
            .addAction(title: "Cancel", style: .destructive)
        
        let alertController = alertBuilder.build()
        present(alertController, animated: true)
    }
    
    private func editTask(at indexPath: IndexPath) {
        showAlert(withTaskAt: indexPath.row) { [unowned self] title, note in
            if indexPath.section == 0 {
                currentTasks[indexPath.row].title = title
                currentTasks[indexPath.row].title = note
            } else {
                completedTasks[indexPath.row].title = title
                completedTasks[indexPath.row].note = note
            }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
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
        taskLists = storageManager.fetchData()
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        guard let index = taskLists[taskListIndex].tasks.firstIndex(of: task) else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        showAlert(withTaskAt: index) { [unowned self] title, note in
            if indexPath.section == 0 {
                currentTasks[indexPath.row].title = title
                currentTasks[indexPath.row].note = note
            } else {
                completedTasks[indexPath.row].title = title
                completedTasks[indexPath.row].note = note
            }
            delegate.editTask(at: index, inTaskListAt: taskListIndex, withTitle: title, andNote: note)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        guard let taskIndex = taskLists[taskListIndex].tasks.firstIndex(of: task) else { return UISwipeActionsConfiguration() }
        
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete") { [unowned self]  _, _, _ in
                if indexPath.section == 0 {
                    currentTasks.remove(at: indexPath.row)
                } else {
                    completedTasks.remove(at: indexPath.row)
                }
                taskLists[taskListIndex].tasks.remove(at: taskIndex)
                delegate.deleteTask(at: taskIndex, inTaskListAt: taskListIndex)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        
        let editAction = UIContextualAction(
            style: .normal,
            title: "Edit") { [unowned self] _, _, isDone in
                showAlert(withTaskAt: indexPath.row) { [unowned self] title, note in
                    if indexPath.section == 0 {
                        currentTasks[indexPath.row].title = title
                        currentTasks[indexPath.row].note = note
                    } else {
                        completedTasks[indexPath.row].title = title
                        completedTasks[indexPath.row].note = note
                    }
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
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
                taskLists[taskListIndex].tasks[taskIndex].isComplete.toggle()
                delegate.doneTask(at: taskIndex, inTaskListAt: taskListIndex)
                
                tableView.reloadData()
            }
        
        editAction.backgroundColor = .systemOrange
        doneAction.backgroundColor = .systemGreen
        
        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }
}

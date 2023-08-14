//
//  TaskListViewController.swift
//  TestRealm
//
//  Created by Alexey Turulin on 8/7/23.
//

import UIKit

protocol TasksViewControllerDelegate: AnyObject {
    func add(_ task: Task, toTaskListAt index: Int)
    func deleteTask(at taskIndex: Int, inTaskListAt taskListIndex: Int)
    func doneTask(at taskIndex: Int, inTaskListAt taskListIndex: Int)
    func editTask(at taskIndex: Int, inTaskListAt taskListIndex: Int, withTitle newTitle: String, andNote note: String?)
}

final class TaskListViewController: UITableViewController {

    // MARK: - Private Properties
    private let cellID = "taskList"
    private var taskLists: [TaskList] = []
    private let storageManager = StorageManager.shared

    // MARK: - UIViews
    private lazy var segmentedControl: UISegmentedControl = {
        let items = ["Date", "A-Z"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.addTarget(self, action: #selector(sortTaskLists), for: .valueChanged)
        return segmentedControl
    }()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        setupNavigationBar()
        
        setupSegmentedControl()
        
        taskLists = storageManager.fetchData()
    }

    // MARK: - Private Methods
    @objc private func addTaskList() {
        showAlert()
    }
    
    @objc private func sortTaskLists() {
        taskLists.sort { segmentedControl.selectedSegmentIndex == 0 ? $0.data < $1.data : $0.title < $1.title }
        storageManager.save(taskLists)
        
        var indexPaths: [IndexPath] = []
        
        for index in 0..<taskLists.count {
            let indexPath = IndexPath(row: index, section: 0)
            indexPaths.append(indexPath)
        }
        
        tableView.reloadRows(at: indexPaths, with: .automatic)
    }
    
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true

        navigationItem.leftBarButtonItem = editButtonItem
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTaskList)
        )
    }
    
    private func setupSegmentedControl() {
        tableView.tableHeaderView = segmentedControl

        NSLayoutConstraint.activate(
            [
                segmentedControl.widthAnchor.constraint(equalTo: tableView.widthAnchor, multiplier: 1)
            ]
        )
    }
}

// MARK: - Task List
extension TaskListViewController {
    private func save(taskList: String) {
        let taskList = TaskList(title: taskList, data: Date(), tasks: [])
        taskLists.append(taskList)
        storageManager.save(taskList)
        tableView.reloadData()
    }
    
    private func showAlert(withTaskListAt index: Int? = nil, completion: (() -> Void)? = nil) {
        let alertBuilder = AlertControllerBuilder(
            title: index != nil ? "Edit List" : "New List",
            message: "Please set title for new task list"
        )
        
        alertBuilder
            .setTextField(index != nil ? taskLists[index ?? 0].title : "")
            .addAction(
                title: index != nil ? "Update List" : "Save List",
                style: .default) { [weak self] title, _ in
                    if let index, let completion {
                        self?.taskLists[index].title = title
                        self?.storageManager.editTaskList(at: index, newValue: title)
                        completion()
                        return
                    }
                    self?.save(taskList: title)
                }
            .addAction(title: "Cancel", style: .destructive)
        
        let alertController = alertBuilder.build()
        present(alertController, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskLists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        var content = cell.defaultContentConfiguration()
        let taskList = taskLists[indexPath.row]
        
        content.text = taskList.title
        cell.contentConfiguration = content
        
        let detailsLabel = UILabel()
        detailsLabel.text = taskList.tasks.count.formatted()
        detailsLabel.textColor = .systemGray
        detailsLabel.sizeToFit()
        cell.accessoryView = detailsLabel
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tasksVC = TasksViewController()
        tasksVC.delegate = self
        tasksVC.taskListIndex = indexPath.row
        show(tasksVC, sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete") { [unowned self] _, _, _ in
                taskLists.remove(at: indexPath.row)
                storageManager.deleteTaskList(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        
        let editAction = UIContextualAction(
            style: .normal,
            title: "Edit") { [unowned self] _, _, isDone in
                self.showAlert(withTaskListAt: indexPath.row) {
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
                isDone(true)
            }
        
        let doneAction = UIContextualAction(
            style: .normal,
            title: "Done") { [unowned self] _, _, isDone in
                let index = indexPath.row
                let tasks = taskLists[indexPath.row].tasks.count
                for taskIndex in 0..<tasks {
                    taskLists[index].tasks[taskIndex].isComplete = true
                }
                storageManager.doneTaskList(at: index)
                tableView.reloadRows(at: [indexPath], with: .automatic)
                isDone(true)
            }
        
        editAction.backgroundColor = .systemOrange
        doneAction.backgroundColor = .systemGreen
        
        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }
}

// MARK: - TasksViewControllerDelegate
extension TaskListViewController: TasksViewControllerDelegate {
    func add(_ task: Task, toTaskListAt index: Int) {
        taskLists[index].tasks.append(task)
        storageManager.save(task, toTaskListAt: index)
        tableView.reloadData()
    }
    
    func deleteTask(at taskIndex : Int, inTaskListAt taskListIndex: Int) {
        taskLists[taskListIndex].tasks.remove(at: taskIndex)
        storageManager.deleteTask(at: taskIndex, inTaskListAt: taskListIndex)
        tableView.reloadData()
    }
    
    func doneTask(at taskIndex: Int, inTaskListAt taskListIndex: Int) {
        taskLists[taskListIndex].tasks[taskIndex].isComplete.toggle()
        storageManager.doneTask(at: taskIndex, inTaskListAt: taskListIndex)
        tableView.reloadData()
    }
    
    func editTask(at taskIndex: Int, inTaskListAt taskListIndex: Int, withTitle title: String, andNote note: String? = nil) {
        taskLists[taskListIndex].tasks[taskIndex].title = title
        if let note {
            taskLists[taskListIndex].tasks[taskIndex] .note = note
        }
        storageManager.editTask(at: taskIndex, inTaskListAt: taskListIndex, withTitle: title, andNote: note)
        tableView.reloadData()
    }
}

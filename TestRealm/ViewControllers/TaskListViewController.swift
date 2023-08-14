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
        let number = taskLists.count
        let taskList = TaskList(title: "Task List \(number)", data: Date(), tasks: [])
        taskLists.append(taskList)
        storageManager.save(taskList)
        tableView.reloadData()
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
        
        if taskList.tasks.count == 0 || taskList.tasks.contains(where: { !$0.isComplete }) {
            let detailsLabel = UILabel()
            detailsLabel.text = taskList.tasks.count.formatted()
            detailsLabel.textColor = .systemGray
            detailsLabel.sizeToFit()
            cell.accessoryView = detailsLabel
        } else if taskList.tasks.count > 0 {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tasksVC = TasksViewController()
        tasksVC.delegate = self
        tasksVC.taskList = taskLists[indexPath.row]
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
            title: "Edit") { _, _, isDone in
                
                isDone(true)
            }
        
        let doneAction = UIContextualAction(
            style: .normal,
            title: "Done") { [unowned self] _, _, isDone in
                for taskIndex in 0..<taskLists[indexPath.row].tasks.count {
                    taskLists[indexPath.row].tasks[taskIndex].isComplete = true
                }
                storageManager.doneTaskList(at: indexPath.row)
                tableView.reloadData()
                isDone(true)
            }
        
        editAction.backgroundColor = .systemOrange
        doneAction.backgroundColor = .systemGreen
        
        return UISwipeActionsConfiguration(actions: [doneAction, deleteAction])
    }
}

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
}

//
//  TaskListViewController.swift
//  TestRealm
//
//  Created by Alexey Turulin on 8/7/23.
//

import UIKit

class TaskListViewController: UITableViewController {
    
    // MARK: - Properties
//    var taskLists: [TaskList] = []
    
    // MARK: - Private Properties
    private let cellID = "taskList"
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
        
        tableView.tableHeaderView = segmentedControl
        
        setupConstraints()
        
        fetchTaskLists()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    // MARK: - Private Methods
    @objc private func addTaskList() {
        let number = storageManager.taskLists.count
        let taskList = TaskList(title: "Task List \(number)", data: Date(), tasks: [])
        storageManager.taskLists.append(taskList)
        storageManager.save()
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
    
    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                segmentedControl.widthAnchor.constraint(equalTo: tableView.widthAnchor, multiplier: 1)
            ]
        )
    }
    
    private func fetchTaskLists() {
        storageManager.fetchData()
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        storageManager.taskLists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let detailLabel = UILabel()
        var content = cell.defaultContentConfiguration()
        let taskList = storageManager.taskLists[indexPath.row]
        
        cell.accessoryView = detailLabel
        content.text = taskList.title
        cell.contentConfiguration = content
        
        detailLabel.text = taskList.tasks.count.formatted()
        detailLabel.sizeToFit()
        detailLabel.textColor = .systemGray
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tasksVC = TasksViewController()
        tasksVC.taskListIndexPath = indexPath
        show(tasksVC, sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete") { [unowned self] _, _, _ in
                storageManager.taskLists.remove(at: indexPath.row)
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

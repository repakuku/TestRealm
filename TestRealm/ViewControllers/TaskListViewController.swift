//
//  TaskListViewController.swift
//  TestRealm
//
//  Created by Alexey Turulin on 8/7/23.
//

import UIKit

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
    }

    // MARK: - Private Methods
    @objc private func addTaskList() {
        showAlert()
    }
    
    @objc private func sortTaskLists() {
        sort()
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
            [segmentedControl.widthAnchor.constraint(equalTo: tableView.widthAnchor, multiplier: 1)]
        )
    }
}

// MARK: - Task List
extension TaskListViewController {
    private func save(taskList: String) {

    }
    
    private func showAlert(with taskList: TaskList? = nil, completion: (() -> Void)? = nil) {
        let alertBuilder = AlertControllerBuilder(
            title: taskList != nil ? "Edit List" : "New List",
            message: "Please set title for new task list"
        )
        
        alertBuilder
            .setTextField(taskList?.title)
            .addAction(
                title: taskList != nil ? "Update List" : "Save List",
                style: .default) { [weak self] title, _ in
                    if let taskList, let completion {
                        
                        completion()
                        return
                    }
                    self?.save(taskList: title)
                }
            .addAction(title: "Cancel", style: .destructive)
        
        let alertController = alertBuilder.build()
        present(alertController, animated: true)
    }
    
    private func sort() {
        taskLists.sort { segmentedControl.selectedSegmentIndex == 0 ? $0.data < $1.data : $0.title < $1.title }
        
        var indexPaths: [IndexPath] = []
        
        for index in 0..<taskLists.count {
            let indexPath = IndexPath(row: index, section: 0)
            indexPaths.append(indexPath)
        }
        
        tableView.reloadRows(at: indexPaths, with: .automatic)
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
        //
        show(tasksVC, sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete") { [unowned self] _, _, _ in
                //
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        
        let editAction = UIContextualAction(
            style: .normal,
            title: "Edit") { [unowned self] _, _, isDone in
                //
                isDone(true)
            }
        
        let doneAction = UIContextualAction(
            style: .normal,
            title: "Done") { [unowned self] _, _, isDone in
                //
                isDone(true)
            }
        
        editAction.backgroundColor = .systemOrange
        doneAction.backgroundColor = .systemGreen
        
        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }
}

//
//  TaskListViewController.swift
//  TestRealm
//
//  Created by Alexey Turulin on 8/7/23.
//

import UIKit
import RealmSwift

final class TaskListViewController: UITableViewController {

    // MARK: - Private Properties
    private let cellID = "taskList"
    private var taskLists: Results<TaskList>!
    private let storageManager = StorageManager.shared
    private let dataManager = DataManager.shared

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
        
        taskLists = storageManager.realm.objects(TaskList.self).sorted(byKeyPath: "date")
        createTempData()
        
        setupNavigationBar()
        setupSegmentedControl()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    // MARK: - Private Methods
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
    
    @objc private func addTaskList() {
        showAlert()
    }
    
    @objc private func sortTaskLists() {
        sort()
    }
    
    private func sort() {
        let keyPath = segmentedControl.selectedSegmentIndex == 0 ? "date" : "title"
        taskLists = taskLists.sorted(byKeyPath: keyPath)
        
        var indexPaths: [IndexPath] = []
        
        for index in 0..<taskLists.count {
            let indexPath = IndexPath(row: index, section: 0)
            indexPaths.append(indexPath)
        }
        
        tableView.reloadRows(at: indexPaths, with: .automatic)
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
                style: .default) { [weak self] newTitle, _ in
                    if let taskList, let completion {
                        self?.storageManager.edit(taskList, newTitle: newTitle)
                        completion()
                        return
                    }
                    self?.save(taskList: newTitle)
                }
            .addAction(title: "Cancel", style: .destructive)
        
        let alertController = alertBuilder.build()
        present(alertController, animated: true)
    }
    
    private func save(taskList: String) {
        storageManager.save(taskList) { taskList in
            let rowIndex = IndexPath(row: taskLists.index(of: taskList) ?? 0, section: 0)
            tableView.insertRows(at: [rowIndex], with: .automatic)
        }
    }
    
    private func createTempData() {
        if !UserDefaults.standard.bool(forKey: "done") {
            dataManager.createTempData { [unowned self] in
                UserDefaults.standard.set(true, forKey: "done")
                tableView.reloadData()
            }
        }
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

        #warning("TODO: fix it")
        if taskList.tasks.contains(where: { !$0.isComplete }) || taskList.tasks.count == 0 {
            let detailsLabel = UILabel()
            detailsLabel.text = taskList.tasks.count.formatted()
            detailsLabel.textColor = .systemGray
            detailsLabel.sizeToFit()
            cell.accessoryView = detailsLabel
        } else {
            cell.accessoryType = .checkmark
        }
        
        content.text = taskList.title
        cell.contentConfiguration = content
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tasksVC = TasksViewController()
        tasksVC.taskList = taskLists[indexPath.row]
        show(tasksVC, sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let taskList = taskLists[indexPath.row]
        
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete") { [unowned self] _, _, _ in
                storageManager.delete(taskList)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        
        let editAction = UIContextualAction(
            style: .normal,
            title: "Edit") { [unowned self] _, _, isDone in
                showAlert(with: taskList) {
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
                isDone(true)
            }
        
        let doneAction = UIContextualAction(
            style: .normal,
            title: "Done") { [unowned self] _, _, isDone in
                storageManager.done(taskList)
                tableView.reloadRows(at: [indexPath], with: .automatic)
                isDone(true)
            }
        
        editAction.backgroundColor = .systemOrange
        doneAction.backgroundColor = .systemGreen
        
        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }
}

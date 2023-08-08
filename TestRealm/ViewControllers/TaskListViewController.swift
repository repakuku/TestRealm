//
//  TaskListViewController.swift
//  TestRealm
//
//  Created by Alexey Turulin on 8/7/23.
//

import UIKit

class TaskListViewController: UITableViewController {
    
    // MARK: - Private Properties
    private let cellID = "taskList"

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
    }

    // MARK: - Private Methods
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true

        navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .edit)
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .add)
    }
    
    private func setupConstraints() {
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
        1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = "Text"
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        show(TasksViewController(), sender: nil)
    }
}

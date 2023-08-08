//
//  TasksViewController.swift
//  TestRealm
//
//  Created by Alexey Turulin on 8/7/23.
//

import UIKit

class TasksViewController: UITableViewController {
    
    // MARK: - Private Properties
    private let cellID = "tasks"

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        setupNavigationBar()
    }
    
    // MARK: - Private Methods
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true

        let editButton = UIBarButtonItem(systemItem: .edit)
        let addButton = UIBarButtonItem(systemItem: .add)
        
        navigationItem.rightBarButtonItems = [addButton, editButton]
    }
    
}

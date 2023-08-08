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
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let editButton = editButtonItem
        let addButton = UIBarButtonItem(systemItem: .add)
        
        navigationItem.rightBarButtonItems = [addButton, editButton]
    }
    
}

extension TasksViewController {
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

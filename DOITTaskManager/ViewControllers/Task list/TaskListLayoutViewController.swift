//
//  TaskListLayoutViewController.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 1/30/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

import UIKit

class TaskListLayoutViewController: UIViewController, TaskListLayoutController {
    // MARK: - Inner types
    
    private struct Constants {
        static let taskListCellReuseIdentifier = "TaskListCell"
    }
    
    
    
    // MARK: - Properties
    
    
    @IBOutlet private weak var tableView: UITableView!
    
    

    // MARK: - LoginLayoutController
    
    weak var delegate: TaskListLayoutControllerDelegate?
    var tasks: [Task] = [] {
        didSet {
            guard isViewLoaded else { return }
            tableView.reloadData()
        }
    }
    
    
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    
    
    // MARK: - Private
    
    private func configureUI() {
        
    }
}



extension TaskListLayoutViewController: UITableViewDelegate {
    
}



extension TaskListLayoutViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.taskListCellReuseIdentifier) as? TaskListTableViewCell,
            tasks.indices.contains(indexPath.row) else {
                return UITableViewCell()
        }
        let task = tasks[indexPath.row]
        cell.update(with: task)
        return cell
    }
}

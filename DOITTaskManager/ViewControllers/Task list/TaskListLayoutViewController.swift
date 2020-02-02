//
//  TaskListLayoutViewController.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 1/30/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

import UIKit
import DropDown

class TaskListLayoutViewController: UIViewController, TaskListLayoutController {
    // MARK: - Inner types
    
    private struct Constants {
        static let taskListCellReuseIdentifier = "TaskListCell"
    }
    
    
    
    // MARK: - Properties
    
    @IBOutlet private weak var tableView: UITableView!
    private var refreshControl = UIRefreshControl()
    private let dropDown = DropDown()
    
    

    // MARK: - LoginLayoutController
    
    weak var delegate: TaskListLayoutControllerDelegate?
    var tasks: [Task] = [] {
        didSet {
            guard isViewLoaded else { return }
            refreshControl.endRefreshing()
            tableView.reloadData()
        }
    }
    
    func showDropdown(preselectedIndex: Int?) {
        if let preselectedIndex = preselectedIndex,
            dropDown.selectedItem == nil {
            dropDown.selectRow(at: preselectedIndex)
        }
        dropDown.show()
    }
    
    
    
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    
    
    // MARK: - Private
    
    private func configureUI() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        dropDown.anchorView = view
        dropDown.dataSource = SortingOption.allTypes.map { $0.rawValue }
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            let allOptions = SortingOption.allTypes
            guard let `self` = self, allOptions.indices.contains(index) else {
                return
            }
            let selectedOption = allOptions[index]
            self.delegate?.layoutController(self, didAskToSortBy: selectedOption)
        }
        dropDown.width = 200
        dropDown.direction = .bottom
        dropDown.bottomOffset = CGPoint(x: DeviceInfo.screenSize.width-200, y: 0)
    }
    
    
    
    // MARK: - Actions
    
    @IBAction private func addButtonPressed(_ sender: Any) {
        delegate?.layoutControllerDidAskToAddTask(self)
    }
    
    @objc private func refresh(sender:AnyObject) {
        delegate?.layoutControllerDidAskToRefresh(self)
    }
}



extension TaskListLayoutViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.layoutController(self, didAskToSelectRowWith: indexPath.item)
    }
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

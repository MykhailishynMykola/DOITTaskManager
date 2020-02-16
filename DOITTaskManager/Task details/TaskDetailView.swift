//
//  TaskDetailView.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 2/16/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

import UIKit

class TaskDetailView: ScreenViewController, TaskDetailViewProtocol {
    // MARK: - Properties
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var priorityLabel: UILabel!
    
    var presenter: TaskDetailPresenterProtocol?
    
    
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
    }
    
    override func backButtonTapped() {
        presenter?.backButtonTapped()
    }
    
    override func configureNavigationBar() {
        super.configureNavigationBar()
        presenter?.configureNavigation(with: navigationItem)
    }
    
    
    
    // MARK: - TaskDetailViewProtocol
    
    func showTaskDetail(with task: Task) {
        titleLabel.text = task.title
        let date = Date(timeIntervalSince1970: task.expirationDate)
        dateLabel.text = date.represent(as: "EEEE dd MMM, yyyy")
        priorityLabel.text = task.priority.string
    }
    
    
    
    // MARK: - Private
    // MARK: - Actions
    
    @IBAction private func deleteButtonPressed(_ sender: Any) {
        presenter?.deleteButtonPressed()
    }
}

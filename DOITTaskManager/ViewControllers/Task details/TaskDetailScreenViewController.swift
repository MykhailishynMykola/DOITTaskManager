//
//  TaskDetailScreenViewController.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 1/30/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

import UIKit
import Swinject

class TaskDetailScreenViewController: ScreenViewController {
    // MARK: - Inner types
    
    private enum SegueIdentifier: String {
        case showLayout = "showLayout"
    }
    
    
    
    // MARK: - Properties
    
    var taskIdentifier: Int?
    
    private weak var layoutController: TaskDetailLayoutContoller?
    private var taskManager: TaskManager? {
        didSet {
            update()
        }
    }
    
    
    
    // MARK: - Overrides
    
    override func configureNavigationBar() {
        super.configureNavigationBar()
        navigationItem.title = "Task Details"
        
        let listImage = UIImage(systemName: "pencil")
        let listButton = UIBarButtonItem(image: listImage, style: .plain, target: self, action: #selector(editButtonPressed))
        navigationItem.rightBarButtonItem  = listButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        update()
    }
    
    override func setupDependencies(with resolver: Resolver) {
        super.setupDependencies(with: resolver)
        taskManager = resolver.resolve(TaskManager.self)
    }
    
    override func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        switch identifier {
        case SegueIdentifier.showLayout.rawValue:
            let layoutController = segue.destination as? TaskDetailLayoutContoller
            layoutController?.delegate = self
            self.layoutController = layoutController
        default:
            break
        }
    }
    
    
    
    // MARK: - Public
    
    func update() {
        guard let taskIdentifier = taskIdentifier else {
            return
        }
        taskManager?.getTaskDetails(by: taskIdentifier)
            .then { [weak self] task in
                self?.layoutController?.task = task
            }
            .catch { [weak self] error in
                self?.handleError(error)
        }
    }
    
    
    
    // MARK: - Actions
    
    @objc private func editButtonPressed() {
        guard let editTaskViewController = presentViewController(withIdentifier: "EditTask", fromNavigation: true) as? EditTaskScreenViewController else {
            return
        }
        editTaskViewController.taskIdentifier = taskIdentifier
    }
}



extension TaskDetailScreenViewController: TaskDetailLayoutContollerDelegate {
    func layoutControllerDidAskToRemoveTask(_ layoutController: TaskDetailLayoutContoller) {
        showDeleteError() { [weak self] in self?.deleteTask() }
    }
    
    private func deleteTask() {
        guard let taskIdentifier = taskIdentifier else {
            return
        }
        taskManager?.deleteTask(with: taskIdentifier)
            .then { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .catch { [weak self] error in
                self?.handleError(error)
        }
    }
}

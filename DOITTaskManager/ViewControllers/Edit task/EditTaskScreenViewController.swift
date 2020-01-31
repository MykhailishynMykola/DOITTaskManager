//
//  EditTaskScreenViewController.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 1/31/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

import UIKit
import Swinject
import PromiseKit

class EditTaskScreenViewController: ScreenViewController {
    // MARK: - Inner types
    
    private enum SegueIdentifier: String {
        case showLayout = "showLayout"
    }
    
    enum Style {
        case addTask
        case editTask
    }
    
    
    
    // MARK: - Properties
    
    var taskIdentifier: Int?
    var style: Style = .editTask
    
    private weak var layoutController: EditTaskLayoutContoller?
    private var taskManager: TaskManager? {
        didSet {
            update()
        }
    }
    
    override var hideKeyboardWhenTappedAround: Bool {
        return true
    }
    
    
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
    }
    
    override func setupDependencies(with resolver: Resolver) {
        super.setupDependencies(with: resolver)
        taskManager = resolver.resolve(TaskManager.self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        switch identifier {
        case SegueIdentifier.showLayout.rawValue:
            let layoutController = segue.destination as? EditTaskLayoutContoller
            layoutController?.delegate = self
            layoutController?.style = style
            self.layoutController = layoutController
        default:
            break
        }
    }
    
    
    
    // MARK: - Public
    
    func update() {
        if let taskIdentifier = taskIdentifier, style == .editTask {
            taskManager?.getTaskDetails(by: taskIdentifier)
                .then { [weak self] task in
                    self?.layoutController?.task = task
            }
            return
        }
    }
    
    
    
    // MARK: - Private
    
    private func configureNavigationBar() {
        if style == .editTask {
            navigationItem.title = "Edit Task"
            return
        }
        navigationItem.title = "Add Task"
    }
}



extension EditTaskScreenViewController: EditTaskLayoutContollerDelegate {
    func layoutControllerDidAskToRemoveTask(_ layoutController: EditTaskLayoutContoller) {
        showDeleteError() { [weak self] in self?.deleteTask()}
    }
    
    func layoutController(_ layoutController: EditTaskLayoutContoller, didAskToSaveTaskWith title: String, priority: Task.Priority, date: Date) {
        let task = Task(title: title,
                        identifier: taskIdentifier ?? 0,
                        priority: priority.rawValue,
                        expirationDate: date.timeIntervalSince1970)
        let promise: Promise<Void>?
        if style == .editTask {
            promise = taskManager?.updateTask(task)
        }
        else {
            promise = taskManager?.addTask(task)
        }
        promise?.then { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    private func deleteTask() {
        guard let taskIdentifier = taskIdentifier else {
            return
        }
        taskManager?.deleteTask(with: taskIdentifier)
            .then { [weak self] _ in
                self?.navigationController?.popToRootViewController(animated: true)
        }
    }
}

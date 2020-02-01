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
    var style: Style = .editTask {
        didSet {
            guard style == .addTask else { return }
            // Preselect
            openingDate = Date().timeIntervalSince1970
            bufferPriority = .high
            bufferDate = openingDate
        }
    }
    
    private weak var layoutController: EditTaskLayoutContoller?
    private var openingDate: TimeInterval?
    private var task: Task?
    private var bufferTitle: String?
    private var bufferPriority: Task.Priority?
    private var bufferDate: TimeInterval?
    
    private var taskManager: TaskManager? {
        didSet {
            update()
        }
    }
    
    override var hideKeyboardWhenTappedAround: Bool {
        return true
    }
    
    
    
    // MARK: - Overrides
    
    override func configureNavigationBar() {
        super.configureNavigationBar()
        if style == .editTask {
            navigationItem.title = "Edit Task"
            return
        }
        navigationItem.title = "Add Task"
    }
    
    override func setupDependencies(with resolver: Resolver) {
        super.setupDependencies(with: resolver)
        taskManager = resolver.resolve(TaskManager.self)
    }
    
    override func backButtonTapped() {
        let bufferTitleWasChanged = bufferTitle != nil && bufferTitle?.isEmpty != true
        let newTaskWasChanged = style == .addTask
            && (bufferTitleWasChanged || bufferPriority != .high || bufferDate != openingDate)
        let existTaskWasChanged = style == .editTask
            && (bufferTitle != task?.title || bufferPriority != task?.priority || bufferDate != task?.expirationDate)
        guard newTaskWasChanged || existTaskWasChanged else {
            navigationController?.popViewController(animated: true)
            return
        }
        showSaveNotification()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        switch identifier {
        case SegueIdentifier.showLayout.rawValue:
            let layoutController = segue.destination as? EditTaskLayoutContoller
            layoutController?.delegate = self
            layoutController?.shouldShowDeleteButton = style == .editTask
            self.layoutController = layoutController
        default:
            break
        }
    }
    
    
    // MARK: - Private
    
    private func update() {
        guard let taskIdentifier = taskIdentifier, style == .editTask else {
            return
        }
        taskManager?.getTaskDetails(by: taskIdentifier)
            .then { [weak self] task -> Void in
                self?.task = task
                self?.bufferTitle = task.title
                self?.bufferPriority = task.priority
                self?.bufferDate = task.expirationDate
                self?.layoutController?.task = task
        }
    }
    
    private func showSaveNotification() {
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) { [weak self] _ in
                                        self?.saveChangesAndDismiss()
        }
        let closeAction = UIAlertAction(title: "Close",
                                  style: .default) { [weak self] _ in
                                    self?.navigationController?.popViewController(animated: true)
        }
        showError(title: "Notification",
                  message: "Do you want to save these changes?",
                  primaryAction: saveAction,
                  secondaryAction: closeAction)
    }
    
    private func saveChangesAndDismiss() {
        guard let title = bufferTitle, !title.isEmpty else {
            showError(message: "Title couldn't be empty!")
            return
        }
        guard let priority = bufferPriority?.rawValue,
            let expirationDate = bufferDate else {
                return
        }
        let task = Task(title: title,
                        identifier: taskIdentifier ?? 0,
                        priority: priority,
                        expirationDate: expirationDate)
        let promise = style == .editTask ? taskManager?.updateTask(task) : taskManager?.addTask(task)
        promise?.then { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
    }
}



extension EditTaskScreenViewController: EditTaskLayoutContollerDelegate {
    func layoutControllerDidAskToRemoveTask(_ layoutController: EditTaskLayoutContoller) {
        showDeleteError() { [weak self] in self?.deleteTask()}
    }
    
    func layoutControllerDidAskToSaveTask(_ layoutController: EditTaskLayoutContoller) {
        saveChangesAndDismiss()
    }
    
    func layoutController(_ layoutController: EditTaskLayoutContoller, didAskToSetTitleTo title: String) {
        bufferTitle = title
    }
    
    func layoutController(_ layoutController: EditTaskLayoutContoller, didAskToSetPriorityTo priority: Task.Priority) {
        bufferPriority = priority
    }
    
    func layoutController(_ layoutController: EditTaskLayoutContoller, didAskToSetDateTo date: TimeInterval) {
        bufferDate = date
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

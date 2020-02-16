//
//  TaskListScreenViewController.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 1/30/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

import UIKit
import Swinject

class TaskListScreenViewController: ScreenViewController {
    // MARK: - Inner types
    
    private enum SegueIdentifier: String {
        case showLayout = "showLayout"
    }
    
    
    
    // MARK: - Properties
    
    private var tasks: [Task] = []
    private weak var layoutController: TaskListLayoutController?
    private var taskManager: TaskManager?
    private var selectedSortingOption: SortingOption?
    private var preselectedIndex: Int?
    
    
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let rawValue = UserDefaults.standard.string(forKey: "sorting"),
            let index = Int(rawValue),
            SortingOption.allTypes.indices.contains(index) {
            preselectedIndex = index
            selectedSortingOption = SortingOption.allTypes[index]
        }
        update()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        update()
    }
    
    override func configureNavigationBar() {
        super.configureNavigationBar()
        let bellImage = UIImage(systemName: "bell")
        let bellButton = UIBarButtonItem(image: bellImage, style: .plain, target: self, action: #selector(notificationButtonPressed))
        navigationItem.leftBarButtonItem  = bellButton
        
        navigationItem.title = "My Tasks"
        
        let listImage = UIImage(systemName: "list.bullet")
        let listButton = UIBarButtonItem(image: listImage, style: .plain, target: self, action: #selector(sortButtonPressed))
        
        let exitImage = UIImage(systemName: "person.crop.circle.fill")
        let exitButton = UIBarButtonItem(image: exitImage, style: .plain, target: self, action: #selector(exitButtonPressed))
        
        navigationItem.rightBarButtonItems = [exitButton, listButton]
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
            let layoutController = segue.destination as? TaskListLayoutController
            layoutController?.delegate = self
            self.layoutController = layoutController
        default:
            break
        }
    }
    
    
    
    // MARK: - Private
    
    private func update() {
        taskManager?.getTasks(with: selectedSortingOption)
            .then { [weak self] tasks -> Void in
                self?.tasks = tasks
                self?.layoutController?.tasks = tasks
            }
            .catch { [weak self] error in
                self?.handleError(error)
        }
    }
    
    
    
    // MARK: - Actions
    
    @objc private func notificationButtonPressed() {
        presentViewController(withIdentifier: "Reminders", fromNavigation: true)
    }
    
    @objc private func sortButtonPressed() {
        layoutController?.showDropdown(preselectedIndex: preselectedIndex)
    }
    
    @objc private func exitButtonPressed() {
        let logoutAction = UIAlertAction(title: "Logout",
                                       style: .default) { [weak self] _ in
                                        self?.dismiss(animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        showError(title: "Notification",
                  message: "Are you sure you want to log out?",
                  primaryAction: logoutAction,
                  secondaryAction: cancelAction)
    }
}



extension TaskListScreenViewController: TaskListLayoutControllerDelegate {
    func layoutController(_ layoutController: TaskListLayoutController, didAskToSelectRowWith index: Int) {
        guard let detailViewController = presentViewController(withIdentifier: "TaskDetails", fromNavigation: true) as? TaskDetailView,
            tasks.indices.contains(index) else {
            return
        }
        TaskDetailWireFrame.createTaskDetailModule(with: detailViewController, taskIdentifier: tasks[index].identifier)
    }
    
    func layoutController(_ layoutController: TaskListLayoutController, didAskToSortBy option: SortingOption) {
        selectedSortingOption = option
        update()
    }
    
    func layoutControllerDidAskToAddTask(_ layoutController: TaskListLayoutController) {
        guard let editTaskViewController = presentViewController(withIdentifier: "EditTask", fromNavigation: true) as? EditTaskScreenViewController else {
            return
        }
        editTaskViewController.style = .addTask
    }
    
    func layoutControllerDidAskToRefresh(_ layoutController: TaskListLayoutController) {
         update()
    }
}

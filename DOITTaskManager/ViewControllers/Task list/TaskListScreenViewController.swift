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
    
    
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        navigationItem.rightBarButtonItem = listButton
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
    }
    
    
    
    // MARK: - Actions
    
    @objc private func notificationButtonPressed() {
        
    }
    
    @objc private func sortButtonPressed() {
        layoutController?.showDropdown()
    }
}



extension TaskListScreenViewController: TaskListLayoutControllerDelegate {
    func layoutController(_ layoutController: TaskListLayoutController, didAskToSelectRowWith index: Int) {
        guard let detailViewController = presentViewController(withIdentifier: "TaskDetails", fromNavigation: true) as? TaskDetailScreenViewController,
            tasks.indices.contains(index) else {
            return
        }
        detailViewController.taskIdentifier = tasks[index].identifier
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

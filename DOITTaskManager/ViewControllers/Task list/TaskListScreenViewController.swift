//
//  TaskListScreenViewController.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 1/30/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

import UIKit
import Swinject

class TaskListScreenViewController: ScreenViewController, TaskListLayoutControllerDelegate {
    // MARK: - Inner types
    
    private enum SegueIdentifier: String {
        case showLayout = "showLayout"
    }
    
    
    
    // MARK: - Properties
    
    private weak var layoutController: TaskListLayoutController?
    private var taskManager: TaskManager?
    
    
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskManager?.getTasks()
            .then { [weak self] tasks in
                self?.layoutController?.tasks = tasks
        }
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
}

//
//  TaskDetailInteractor.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 2/16/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

class TaskDetailInteractor: TaskDetailInputInteractorProtocol {
    // MARK: - TaskDetailInputInteractorProtocol
    
    weak var presenter: TaskDetailOutputInteractorProtocol?
    private let taskManager = DIContainer.defaultResolver.resolve(TaskManager.self)
    
    func getTask(by identifier: Int) {
        taskManager?.getTaskDetails(by: identifier)
            .then { [weak self] task in
                self?.presenter?.taskWasUpdated(task)
            }
            .catch { _ in }
    }
    
    func deleteTask(by identifier: Int) {
        taskManager?.deleteTask(with: identifier)
            .then { [weak self] _ in
                self?.presenter?.taskWasDeleted()
        }
        .catch { _ in }
    }
}

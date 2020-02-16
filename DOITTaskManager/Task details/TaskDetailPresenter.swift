//
//  TaskDetailPresenter.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 2/16/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

import UIKit

class TaskDetailPresenter: TaskDetailPresenterProtocol {
    // MARK: - TaskDetailPresenterProtocol
    
    weak var view: (UIViewController & TaskDetailViewProtocol)?
    var interactor: TaskDetailInputInteractorProtocol?
    var wireframe: TaskDetailWireFrameProtocol?
    var taskIdentifier: Int?
    
    func viewDidLoad() {
        guard let taskIdentifier = taskIdentifier else {
            return
        }
        interactor?.getTask(by: taskIdentifier)
    }
    
    func configureNavigation(with navigationItem: UINavigationItem) {
        navigationItem.title = "Task Details"
        
        let listImage = UIImage(systemName: "pencil")
        let listButton = UIBarButtonItem(image: listImage, style: .plain, target: self, action: #selector(editButtonPressed))
        navigationItem.rightBarButtonItem  = listButton
    }
    
    func deleteButtonPressed() {
        guard let taskIdentifier = taskIdentifier else {
            return
        }
        interactor?.deleteTask(by: taskIdentifier)
    }
    
    func backButtonTapped() {
        guard let view = view else {
            return
        }
        wireframe?.goBackToTaskListView(from: view)
    }
    
    
    
    // MARK: - Private
    
    @objc private func editButtonPressed() {
        guard let taskIdentifier = taskIdentifier,
            let view = view else {
                return
        }
        wireframe?.openEditPage(by: taskIdentifier, from: view)
    }
}



extension TaskDetailPresenter: TaskDetailOutputInteractorProtocol {
    func taskWasUpdated(_ task: Task) {
        view?.showTaskDetail(with: task)
    }
    
    func taskWasDeleted() {
        guard let view = view else {
            return
        }
        wireframe?.goBackToTaskListView(from: view)
    }
}

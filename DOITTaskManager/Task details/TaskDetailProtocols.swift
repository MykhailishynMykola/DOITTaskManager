//
//  TaskDetailProtocols.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 2/16/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

import UIKit

protocol TaskDetailPresenterProtocol: class {
    // View -> Presenter
    
    var interactor: TaskDetailInputInteractorProtocol? { get set }
    var wireframe: TaskDetailWireFrameProtocol? { get set }
    var view: (UIViewController & TaskDetailViewProtocol)? { get set }
    var taskIdentifier: Int? { get set }
    
    func viewDidLoad()
    func configureNavigation(with navigationItem: UINavigationItem)
    func deleteButtonPressed()
    func backButtonTapped()
}

protocol TaskDetailViewProtocol: class {
    // Presenter -> View
    
    func showTaskDetail(with task: Task)
}

protocol TaskDetailWireFrameProtocol: class {
    // Presenter -> WireFrame
    
    func goBackToTaskListView(from view: UIViewController)
    func openEditPage(by identifier: Int, from view: UIViewController)
}

protocol TaskDetailInputInteractorProtocol: class {
    // Presenter -> Interactor
    
    var presenter: TaskDetailOutputInteractorProtocol? { get set }
    
    func getTask(by identifier: Int)
    func deleteTask(by identifier: Int)
}

protocol TaskDetailOutputInteractorProtocol: class {
    // Interactor -> Presenter
    
    func taskWasUpdated(_ task: Task)
    func taskWasDeleted()
}

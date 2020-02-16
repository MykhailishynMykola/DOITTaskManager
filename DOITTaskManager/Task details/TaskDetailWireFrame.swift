//
//  TaskDetailWireFrame.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 2/16/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

import UIKit

class TaskDetailWireFrame: TaskDetailWireFrameProtocol {
    class func createTaskDetailModule(with view: TaskDetailView, taskIdentifier: Int) {
        let presenter = TaskDetailPresenter()
        presenter.taskIdentifier = taskIdentifier
        view.presenter = presenter
        view.presenter?.view = view
        view.presenter?.wireframe = TaskDetailWireFrame()
        view.presenter?.interactor = TaskDetailInteractor()
        view.presenter?.interactor?.presenter = presenter
    }
    
    
    
    // MARK: - TaskDetailWireFrameProtocol
    
    func goBackToTaskListView(from view: UIViewController) {
        view.navigationController?.popViewController(animated: true)
    }
    
    func openEditPage(by identifier: Int, from view: UIViewController) {
        guard let editTaskViewController = view.presentViewController(withIdentifier: "EditTask", fromNavigation: true) as? EditTaskScreenViewController else {
            return
        }
        editTaskViewController.taskIdentifier = identifier
    }
}

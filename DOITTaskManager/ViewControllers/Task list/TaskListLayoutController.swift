//
//  TaskListLayoutController.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 1/30/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

protocol TaskListLayoutController: class {
    var delegate: TaskListLayoutControllerDelegate? { get set }
    var tasks: [Task] { get set }
    
    func showDropdown(preselectedIndex: Int?)
}



protocol TaskListLayoutControllerDelegate: class {
    func layoutController(_ layoutController: TaskListLayoutController, didAskToSelectRowWith index: Int)
    func layoutController(_ layoutController: TaskListLayoutController, didAskToSortBy option: SortingOption)
    func layoutControllerDidAskToAddTask(_ layoutController: TaskListLayoutController)
    func layoutControllerDidAskToRefresh(_ layoutController: TaskListLayoutController)
}

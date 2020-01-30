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
}



protocol TaskListLayoutControllerDelegate: class {
    
}

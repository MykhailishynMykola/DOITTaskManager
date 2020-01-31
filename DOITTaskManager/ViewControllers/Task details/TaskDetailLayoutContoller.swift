//
//  TaskDetailLayoutContoller.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 1/30/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

protocol TaskDetailLayoutContoller: class {
    var delegate: TaskDetailLayoutContollerDelegate? { get set }
    var task: Task? { get set }
}



protocol TaskDetailLayoutContollerDelegate: class {
    func layoutControllerDidAskToRemoveTask(_ layoutController: TaskDetailLayoutContoller)
}

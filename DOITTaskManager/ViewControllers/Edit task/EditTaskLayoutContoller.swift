//
//  EditTaskLayoutContoller.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 1/31/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

import Foundation

protocol EditTaskLayoutContoller: class {
    var delegate: EditTaskLayoutContollerDelegate? { get set }
    var task: Task? { get set }
    var style: EditTaskScreenViewController.Style? { get set }
}



protocol EditTaskLayoutContollerDelegate: class {
    func layoutControllerDidAskToRemoveTask(_ layoutController: EditTaskLayoutContoller)
    func layoutController(_ layoutController: EditTaskLayoutContoller, didAskToSaveTaskWith title: String, priority: Task.Priority, date: Date)
}


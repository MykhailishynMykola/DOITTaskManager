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
    var shouldShowDeleteButton: Bool { get set }
}



protocol EditTaskLayoutContollerDelegate: class {
    func layoutControllerDidAskToRemoveTask(_ layoutController: EditTaskLayoutContoller)
    func layoutControllerDidAskToSaveTask(_ layoutController: EditTaskLayoutContoller)
    
    func layoutController(_ layoutController: EditTaskLayoutContoller, didAskToSetTitleTo title: String)
    func layoutController(_ layoutController: EditTaskLayoutContoller, didAskToSetPriorityTo priority: Task.Priority)
    func layoutController(_ layoutController: EditTaskLayoutContoller, didAskToSetDateTo date: TimeInterval)
    func layoutController(_ layoutController: EditTaskLayoutContoller, didAskToSetNotifyTo notify: Bool)
}


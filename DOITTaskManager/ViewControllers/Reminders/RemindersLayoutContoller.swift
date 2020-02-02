//
//  RemindersLayoutContoller.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 2/2/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

protocol RemindersLayoutContoller: class {
    var delegate: RemindersLayoutContollerDelegate? { get set }
    var reminders: [Reminder] { get set }
}



protocol RemindersLayoutContollerDelegate: class {
    func layoutController(_ layoutController: RemindersLayoutContoller, didAskToRemoveReminderWith identifier: String)
}

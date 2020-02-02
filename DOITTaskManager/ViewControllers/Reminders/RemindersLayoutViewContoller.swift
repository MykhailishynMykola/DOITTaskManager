//
//  RemindersLayoutViewContoller.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 2/2/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

import UIKit

class RemindersLayoutViewContoller: UIViewController, RemindersLayoutContoller {
    // MARK: - Inner types
    
    private struct Constants {
        static let remindersCellReuseIdentifier = "RemindersListCell"
    }
    
    
    
    // MARK: - Properties
    
    @IBOutlet private weak var tableView: UITableView!
    
    
    
    // MARK: - RemindersLayoutContoller
    
    weak var delegate: RemindersLayoutContollerDelegate?
    
    var reminders: [Reminder] = [] {
        didSet {
            guard isViewLoaded else { return }
            tableView.reloadData()
        }
    }
}



extension RemindersLayoutViewContoller: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard reminders.indices.contains(indexPath.row) else { return }
        delegate?.layoutController(self, didAskToRemoveReminderWith: reminders[indexPath.row].identifier)
    }
}



extension RemindersLayoutViewContoller: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.remindersCellReuseIdentifier) as? RemindersTableViewCell,
            reminders.indices.contains(indexPath.row) else {
                return UITableViewCell()
        }
        let reminder = reminders[indexPath.row]
        cell.update(with: reminder)
        return cell
    }
}

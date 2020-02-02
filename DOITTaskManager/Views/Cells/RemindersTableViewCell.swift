//
//  RemindersTableViewCell.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 2/2/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

import UIKit

class RemindersTableViewCell: UITableViewCell {
    // MARK: - Properties
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    
    
    // MARK: - Public
    
    func update(with reminder: Reminder) {
        titleLabel.text = reminder.body
        dateLabel.text = reminder.date.represent(as: "dd/MM/yy HH:mm:ss")
    }
}

//
//  TaskListTableViewCell.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 1/30/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

import UIKit

class TaskListTableViewCell: UITableViewCell {
    // MARK: - Properties
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var priorityLabel: UILabel!
    @IBOutlet private weak var iconView: UIImageView!
    
    
    
    // MARK: - Override
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        iconView.image = UIImage(systemName: "chevron.right")
    }
    
    
    
    
    // MARK: - Public
    
    func update(with task: Task) {
        titleLabel.text = task.title
        priorityLabel.text = task.priority.string
        let date = Date(timeIntervalSince1970: task.expirationDate)
        dateLabel.text = date.represent(as: "dd/MM/yy")
    }
}

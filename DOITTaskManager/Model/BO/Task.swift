//
//  Task.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 1/30/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

import Foundation

class Task {
    // MARK: - Inner types
    
    enum Priority: String {
        case low = "Low"
        case normal = "Normal"
        case high = "High"
    }
    
    
    
    // MARK: - Properties
    
    let title: String
    let identifier: Int
    let priority: Priority
    let expirationDate: TimeInterval
    
    init(title: String, identifier: Int, priority: String, expirationDate: TimeInterval) {
        self.title = title
        self.identifier = identifier
        self.priority = Priority(rawValue: priority) ?? .normal
        self.expirationDate = expirationDate
    }
}

//
//  LocalNotification.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 2/2/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

import Foundation

class LocalNotification {
    // MARK: - Properties
    
    let identifier: String
    let body: String
    let date: Date
    let delivered: Bool
    
    
    
    // MARK: - Init
    
    init(identifier: String, body: String, date: Date, delivered: Bool) {
        self.identifier = identifier
        self.body = body
        self.date = date
        self.delivered = delivered
    }
    
    init(task: Task) {
        self.identifier = "\(task.identifier)"
        self.body = task.title
        let expirationDate = Date(timeIntervalSince1970: task.expirationDate)
        self.date = expirationDate
        self.delivered = expirationDate < Date()
    }
}

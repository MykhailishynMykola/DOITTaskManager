//
//  Task+RawData.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 1/30/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

import Foundation

extension Task {
    convenience init?(rawData: [String: Any]) {
        guard let title = rawData["title"] as? String,
            let id = rawData["id"] as? Int,
            let priority = rawData["priority"] as? String,
            let expirationDate = rawData["dueBy"] as? Int else {
                return nil
        }
        self.init(title: title, identifier: id, priority: priority, expirationDate: TimeInterval(expirationDate))
    }
}

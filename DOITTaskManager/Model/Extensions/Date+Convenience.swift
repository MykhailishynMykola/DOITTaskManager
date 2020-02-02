//
//  Date+Convenience.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 2/2/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

import Foundation

extension Date {
    func represent(as dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd/MM/yy HH:mm:ss"
        return dateFormatter.string(from: self)
    }
}

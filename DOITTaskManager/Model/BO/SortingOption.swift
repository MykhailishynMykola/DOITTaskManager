//
//  SortingOption.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 1/31/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

enum SortingOption: String {
    static var allTypes: [SortingOption] = [.titleAsc, .titleDesc, .priorityAsc, .priorityDesc, .dueToAsc, .dueToDesc]
    
    case titleAsc = "↑ Title"
    case titleDesc = "↓ Title"
    case dueToAsc = "↑ Due to"
    case dueToDesc = "↓ Due to"
    case priorityAsc = "↑ Priority"
    case priorityDesc = "↓ Priority"
    
    var apiPath: String {
        switch self {
        case .titleAsc:
            return "title asc"
        case .titleDesc:
            return "title desc"
        case .priorityAsc:
            return "priority asc"
        case .priorityDesc:
            return "priority desc"
        case .dueToAsc:
            return "dueBy asc"
        case .dueToDesc:
            return "dueBy desc"
        }
    }
}

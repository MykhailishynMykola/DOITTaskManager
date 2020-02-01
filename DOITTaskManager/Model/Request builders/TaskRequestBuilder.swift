//
//  TaskRequestBuilder.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 1/30/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

enum TaskRequestBuilder: RequestBuilder {
    case getTasks(sortingOption: SortingOption?, page: Int, token: String)
    case getDetails(identifier: Int, token: String)
    case deleteTask(identifier: Int, token: String)
    case updateTask(_ task: Task, token: String)
    case addTask(_ task: Task, token: String)
    
    var subpath: String {
        switch self {
        case .getTasks, .addTask:
            return "/tasks"
        case .getDetails(let identifier, _),
             .deleteTask(let identifier, _):
            return "/tasks/\(identifier)"
        case .updateTask(let task, _):
            return "/tasks/\(task.identifier)"
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .getTasks, .getDetails:
            return .get
        case .deleteTask:
            return .delete
        case .updateTask:
            return .put
        case .addTask:
            return .post
        }
    }
    
    var body: [String: Any]? {
        switch self {
        case .getDetails, .getTasks, .deleteTask:
            return nil
        case .updateTask(let task, _),
             .addTask(let task, token: _):
            return ["title": task.title,
                    "dueBy": Int(task.expirationDate),
                    "priority": task.priority.rawValue]
        }
    }
    
    var query: [String: String]? {
        switch self {
        case .getTasks(let sortingOption, let page, _):
            if let sortingOption = sortingOption {
                return ["sort": sortingOption.apiPath, "page": "\(page)"]
            }
            return ["page": "\(page)"]
        default:
            return nil
        }
    }
    
    var authToken: String? {
        switch self {
        case .getDetails(_, let token),
             .getTasks(_, _, let token),
             .deleteTask(_, let token),
             .updateTask(_, let token),
             .addTask(_, let token):
            return token
        }
    }
}

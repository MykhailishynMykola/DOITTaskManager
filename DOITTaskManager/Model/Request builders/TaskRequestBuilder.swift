//
//  TaskRequestBuilder.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 1/30/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

enum TaskRequestBuilder: RequestBuilder {
    case getTasks(token: String)
    
    var subpath: String {
        switch self {
        case .getTasks:
            return "/tasks"
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .getTasks:
            return .get
        }
    }
    
    var body: [String: Any]? {
        switch self {
        case .getTasks:
            return nil
        }
    }
    
    var authToken: String? {
        switch self {
        case .getTasks(let token):
            return token
        }
    }
}

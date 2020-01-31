//
//  AuthRequestBuilder.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 1/30/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

enum AuthRequestBuilder: RequestBuilder {
    case register(email: String, password: String)
    case login(email: String, password: String)
    
    var subpath: String {
        switch self {
        case .login:
            return "/auth"
        case .register:
            return "/users"
        }
    }
    
    var method: RequestMethod {
        return .post
    }
    
    var body: [String: Any]? {
        switch self {
        case .login(let email, let password),
             .register(let email, let password):
            return ["email": email, "password": password]
        }
    }
    
    var query: [String: String]? {
        return nil
    }
    
    var authToken: String? {
        return nil
    }
}

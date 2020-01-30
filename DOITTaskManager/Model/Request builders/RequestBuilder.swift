//
//  RequestBuilder.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 1/30/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

import Foundation
import PromiseKit

private let basePath = "https://testapi.doitserver.in.ua/api"

protocol RequestBuilder {
    var request: Promise<URLRequest> { get }
    var subpath: String { get }
    var method: RequestMethod { get }
    var body: [String: Any]? { get }
    var authToken: String? { get }
}

extension RequestBuilder {
    var request: Promise<URLRequest> {
        let path = "\(basePath)\(subpath)"
        guard let url = URL(string: path) else {
            return Promise(error: RequestBuilderError.wrongPath)
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue.uppercased()
        if let body = body {
            let jsonData = try? JSONSerialization.data(withJSONObject: body)
            request.httpBody = jsonData
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let authToken = authToken {
            request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        return Promise(value: request)
    }
}

/// HTTP request method.
enum RequestMethod: String {
    /// HTTP GET request.
    case get = "GET"
    /// HTTP POST request.
    case post = "POST"
    /// HTTP PUT request.
    case put = "PUT"
    /// HTTP DELETE request.
    case delete = "DELETE"
}

enum RequestBuilderError: Error {
    case wrongPath
}

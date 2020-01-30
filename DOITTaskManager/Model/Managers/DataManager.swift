//
//  DataManager.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 1/30/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

import Swinject
import PromiseKit

class DataManager: ResolverInitializable {
    // MARK: - Init
    
    init() {
        
    }
    
    
    
    // MARK: - ResolverInitializable
    
    required convenience init?(resolver: Resolver) {
        self.init()
        setupDependencies(with: resolver)
    }
    
    
    
    // MARK: - Public
    
    func setupDependencies(with resolver: Resolver) {
        
    }
    
    func getData(with requestBuilder: RequestBuilder) -> Promise<Data> {
        return requestBuilder.request
            .then { [weak self] request -> Promise<Data> in
                guard let `self` = self else { throw NSError.cancelledError() }
                return self.getData(with: request)
        }
    }
    
    
    
    // MARK: - Private
    
    private func getData(with request: URLRequest) -> Promise<Data> {
        return Promise(resolvers: { (fulfill, reject) in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    return reject(error)
                }
                guard let data = data else {
                    return reject(DataManagerError.noResponse)
                }
                fulfill(data)
            }
            task.resume()
        })
    }
    
    private func apiError(withData errorData: NSDictionary) -> DataManagerError {
        var message: String = ""
        if let messageDescription = errorData["message"] as? String {
            message = messageDescription
        }
        if let submessageData = errorData["fields"] as? [String: Any] {
            var submessage: String = ""
            submessageData
                .values
                .forEach { data in
                    if let values = data as? [String] {
                        let sub = submessage.isEmpty ? "" : "\(submessage) "
                        submessage = "\(sub)\(values.joined(separator: " "))"
                    }
            }
            message = "\(message). \(submessage)"
        }
        return DataManagerError.apiError(message: message)
    }
}



enum DataManagerError: Error {
    case noResponse
    case wrongResponseData
    case apiError(message: String)
    case unknownError
}

//
//  AuthManager.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 1/30/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

import Swinject
import PromiseKit

protocol AuthManager {
    var user: User? { get }
    
    
    func login(withEmail email: String, password: String) -> Promise<Void>
    func register(withEmail email: String, password: String) -> Promise<Void>
}


class AuthManagerImp: DataManager, AuthManager {
    // MARK: - Properties
    
    private(set) var user: User?
    
    
    
    // MARK: - AuthManager
    
    func login(withEmail email: String, password: String) -> Promise<Void> {
        return getAuthData(with: .login(email: email, password: password))
    }
    
    func register(withEmail email: String, password: String) -> Promise<Void> {
        return getAuthData(with: .register(email: email, password: password))
    }
    
    
    
    // MARK: - Private
    
    private func getAuthData(with requestBuilder: AuthRequestBuilder) -> Promise<Void> {
        return getData(with: requestBuilder)
            .then { [weak self] data in
                guard let `self` = self else { throw NSError.cancelledError() }
                return self.parseToken(with: data, requestBuilder: requestBuilder)
        }
    }
    
    private func parseToken(with data: Data, requestBuilder: AuthRequestBuilder) -> Promise<Void> {
        return Promise(resolvers: { (fulfill, reject) in
            guard let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                return reject(DataManagerError.wrongResponseData)
            }
            guard let responseData = responseJSON as? [String: String],
                let tokenValue = responseData["token"] else {
                    return reject(AuthError.failed(errorData: responseJSON))
            }
            switch requestBuilder {
            case .login(let email, _),
                 .register(let email, _):
                user = User(identifier: email, token: tokenValue)
                return fulfill(())
            }
            return reject(DataManagerError.wrongResponseData)
        })
    }
}



enum AuthError: Error {
    case noToken
    case failed(errorData: NSDictionary)
}

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
    var token: Token? { get }
    
    func login(withEmail email: String, password: String) -> Promise<Void>
    func register(withEmail email: String, password: String) -> Promise<Void>
}


class AuthManagerImp: DataManager, AuthManager {
    // MARK: - Properties
    
    private(set) var token: Token?
    
    
    
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
                return self.parseToken(with: data)
        }
    }
    
    private func parseToken(with data: Data) -> Promise<Void> {
        return Promise(resolvers: { (fulfill, reject) in
            guard let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) else {
                return reject(DataManagerError.wrongResponseData)
            }
            guard let responseData = responseJSON as? [String: String],
                let tokenValue = responseData["token"] else {
                    return reject(AuthError.noToken)
            }
            token = Token(value: tokenValue)
            return fulfill(())
        })
    }
}



enum AuthError: Error {
    case noToken
}

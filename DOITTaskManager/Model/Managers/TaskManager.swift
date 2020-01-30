//
//  TaskManager.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 1/30/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

import PromiseKit
import Swinject

protocol TaskManager {
    func getTasks() -> Promise<[Task]>
}

class TaskManagerImp: DataManager, TaskManager {
    // MARK: - Properties
    
    private var authManager: AuthManager?
    
    
    
    // MARK: - DataManager
    
    override func setupDependencies(with resolver: Resolver) {
        super.setupDependencies(with: resolver)
        authManager = resolver.resolve(AuthManager.self)
    }
    
    
    
    // MARK: - TaskManager
    
    func getTasks() -> Promise<[Task]> {
        guard let token = authManager?.token else {
            return Promise(error: AuthError.noToken)
        }
        let requestBuilder: TaskRequestBuilder = .getTasks(token: token.value)
        return getData(with: requestBuilder)
            .then { data in
                guard let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                    throw DataManagerError.wrongResponseData
                }
                guard let tasksRawData = responseJSON["tasks"] as? [[String: Any]] else {
                    throw TaskManagerError.noData
                }
                let tasks: [Task] = tasksRawData.compactMap { Task(rawData: $0) }
                return Promise(value: tasks)
        }
    }
}

enum TaskManagerError: Error {
    case noData
}

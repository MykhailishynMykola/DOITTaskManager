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
    func getTasks(with sortingOption: SortingOption?) -> Promise<[Task]>
    func getTaskDetails(by identifier: Int) -> Promise<Task>
    func deleteTask(with identifier: Int) -> Promise<Void>
    func updateTask(_ task: Task) -> Promise<Void>
    func addTask(_ task: Task) -> Promise<Void>
}

class TaskManagerImp: DataManager, TaskManager {
    // MARK: - Properties
    
    private var authManager: AuthManager!
    
    
    
    // MARK: - DataManager
    
    override func setupDependencies(with resolver: Resolver) {
        super.setupDependencies(with: resolver)
        authManager = resolver.resolve(AuthManager.self)
    }
    
    
    
    // MARK: - TaskManager
    
    func getTasks(with sortingOption: SortingOption?) -> Promise<[Task]> {
        guard let token = authManager.token else {
            return Promise(error: AuthError.noToken)
        }
        let requestBuilder: TaskRequestBuilder = .getTasks(sortingOption: sortingOption, token: token.value)
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
    
    func getTaskDetails(by identifier: Int) -> Promise<Task> {
        guard let token = authManager?.token else {
            return Promise(error: AuthError.noToken)
        }
        let requestBuilder: TaskRequestBuilder = .getDetails(identifier: identifier, token: token.value)
        return getData(with: requestBuilder)
            .then { data in
                guard let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                    throw DataManagerError.wrongResponseData
                }
                guard let rawData = responseJSON["task"] as? [String : Any],
                    let task = Task(rawData: rawData) else {
                    throw TaskManagerError.noData
                }
                return Promise(value: task)
        }
    }
    
    func deleteTask(with identifier: Int) -> Promise<Void> {
        guard let token = authManager?.token else {
            return Promise(error: AuthError.noToken)
        }
        let requestBuilder: TaskRequestBuilder = .deleteTask(identifier: identifier, token: token.value)
        return getData(with: requestBuilder).asVoid()
    }
    
    func updateTask(_ task: Task) -> Promise<Void> {
        guard let token = authManager?.token else {
            return Promise(error: AuthError.noToken)
        }
        let requestBuilder: TaskRequestBuilder = .updateTask(task, token: token.value)
        return getData(with: requestBuilder).asVoid()
    }
    
    func addTask(_ task: Task) -> Promise<Void> {
        guard let token = authManager?.token else {
            return Promise(error: AuthError.noToken)
        }
        let requestBuilder: TaskRequestBuilder = .addTask(task, token: token.value)
        return getData(with: requestBuilder).asVoid()
    }
}

enum TaskManagerError: Error {
    case noData
}

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
    private var notificationManager: NotificationManager!
    
    
    
    // MARK: - DataManager
    
    override func setupDependencies(with resolver: Resolver) {
        super.setupDependencies(with: resolver)
        authManager = resolver.resolve(AuthManager.self)
        notificationManager = resolver.resolve(NotificationManager.self)
    }
    
    
    
    // MARK: - TaskManager
    
    func getTasks(with sortingOption: SortingOption?) -> Promise<[Task]> {
        return getTasks(with: sortingOption, page: 1, result: [])
    }
    
    func getTaskDetails(by identifier: Int) -> Promise<Task> {
        guard let token = authManager?.token else {
            return Promise(error: AuthError.noToken)
        }
        let requestBuilder: TaskRequestBuilder = .getDetails(identifier: identifier, token: token.value)
        return getData(with: requestBuilder)
            .then { [weak self] data in
                guard let `self` = self else { throw NSError.cancelledError() }
                guard let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                    throw DataManagerError.wrongResponseData
                }
                guard let rawData = responseJSON["task"] as? [String : Any],
                    let task = Task(rawData: rawData) else {
                        throw TaskManagerError.failed(errorData: responseJSON)
                }
                return self.notificationManager.getNotifications()
                    .then { notifications in
                        guard let notification = notifications.first(where: { $0.identifier == "\(task.identifier)" }), !notification.delivered else {
                            return Promise(value: task)
                        }
                        task.notify = true
                        return Promise(value: task)
                }
        }
    }
    
    func deleteTask(with identifier: Int) -> Promise<Void> {
        guard let token = authManager?.token else {
            return Promise(error: AuthError.noToken)
        }
        let requestBuilder: TaskRequestBuilder = .deleteTask(identifier: identifier, token: token.value)
        return getData(with: requestBuilder)
            .then { [weak self] _ -> Promise<Void> in
                guard let `self` = self else { throw NSError.cancelledError() }
                let identifier = "\(identifier)"
                return self.notificationManager.removeNotifications(with: [identifier])
        }
    }
    
    func updateTask(_ task: Task) -> Promise<Void> {
        guard let token = authManager?.token else {
            return Promise(error: AuthError.noToken)
        }
        let requestBuilder: TaskRequestBuilder = .updateTask(task, token: token.value)
        return getData(with: requestBuilder)
            .then { [weak self] _ -> Promise<Void> in
                guard let `self` = self else { throw NSError.cancelledError() }
                let identifier = "\(task.identifier)"
                return self.notificationManager.removeNotifications(with: [identifier])
            }
            .then { [weak self] _ -> Promise<Void> in
                guard let `self` = self else { throw NSError.cancelledError() }
                guard task.notify else {
                    return Promise(value: ())
                }
                let newNotification = LocalNotification(task: task)
                return self.notificationManager.addNotification(newNotification)
        }
    }
    
    func addTask(_ task: Task) -> Promise<Void> {
        guard let token = authManager?.token else {
            return Promise(error: AuthError.noToken)
        }
        let requestBuilder: TaskRequestBuilder = .addTask(task, token: token.value)
        return getData(with: requestBuilder).then { [weak self] data in
            guard let `self` = self else { throw NSError.cancelledError() }
            guard let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                throw DataManagerError.wrongResponseData
            }
            guard let rawData = responseJSON["task"] as? [String : Any],
                let newTask = Task(rawData: rawData) else {
                    throw TaskManagerError.failed(errorData: responseJSON)
            }
            guard task.notify else {
                return Promise(value: ())
            }
            let newNotification = LocalNotification(task: newTask)
            return self.notificationManager.addNotification(newNotification)
        }
    }
    
    
    
    // MARK: - Private
    
    private func getTasks(with sortingOption: SortingOption?, page: Int, result: [Task]) -> Promise<[Task]> {
        guard let token = authManager.token else {
            return Promise(error: AuthError.noToken)
        }
        let requestBuilder: TaskRequestBuilder = .getTasks(sortingOption: sortingOption, page: page, token: token.value)
        return getData(with: requestBuilder)
            .then { data in
                guard let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                    throw DataManagerError.wrongResponseData
                }
                guard let tasksRawData = responseJSON["tasks"] as? [[String: Any]] else {
                    throw TaskManagerError.failed(errorData: responseJSON)
                }
                let newTasks: [Task] = tasksRawData.compactMap { Task(rawData: $0) }
                guard page == 1 else {
                    return Promise(value: result + newTasks)
                }
                guard let metadata = responseJSON["meta"] as? [String: Int],
                    let pageLimit = metadata["limit"],
                    let totalCount = metadata["count"] else {
                    return Promise(value: newTasks)
                }
                guard totalCount > pageLimit else {
                    return Promise(value: newTasks)
                }
                let totalPages = Int(totalCount / pageLimit) + 1
                var resultPromise = Promise(value: newTasks)
                for i in 2...totalPages {
                    resultPromise = resultPromise.then { [weak self] tasks -> Promise<[Task]> in
                        guard let `self` = self else { return Promise(value: tasks) }
                        return self.getTasks(with: sortingOption, page: i, result: tasks)
                    }
                }
                return resultPromise
        }
    }
}

enum TaskManagerError: Error {
    case failed(errorData: NSDictionary)
}

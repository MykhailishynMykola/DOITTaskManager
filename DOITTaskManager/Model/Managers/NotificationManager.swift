//
//  NotificationManager.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 2/2/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

import UserNotifications
import PromiseKit
import Swinject

protocol NotificationManager {
    func addNotification(_ notification: LocalNotification) -> Promise<Void>
    func removeNotifications(with identifiers: [String]) -> Promise<Void>
    func removeAllNotifications() -> Promise<Void>
    func getNotifications() -> Promise<[LocalNotification]>
}


class NotificationManagerImp: NSObject, NotificationManager, ResolverInitializable {
    // MARK: - Properties
    
    private let center = UNUserNotificationCenter.current()
    private var authManager: AuthManager!
    
    
    
    // MARK: - Init
    
    override init() {
        super.init()
        center.delegate = self
    }
    
    
    
    // MARK: - ResolverInitializable
    
    required convenience init?(resolver: Resolver) {
        self.init()
        setupDependencies(with: resolver)
    }
    
    
    
    // MARK: - Public
    
    func setupDependencies(with resolver: Resolver) {
        authManager = resolver.resolve(AuthManager.self)
    }
    
    
    
    // MARK: - NotificationManager
    
    func addNotification(_ notification: LocalNotification) -> Promise<Void> {
        return checkAccess()
            .then { [weak self] _ -> Promise<Void> in
                guard let `self` = self else { throw NSError.cancelledError() }
                guard let user = self.authManager.user else {
                    throw NotificationManagerError.noUser
                }
                let content = UNMutableNotificationContent()
                content.title = "Reminder:"
                content.userInfo = ["user": user.identifier]
                content.body = notification.body
                content.sound = UNNotificationSound.default
                let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: notification.date)
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                let identifier = notification.identifier
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                return self.registerNotification(request: request)
        }
    }
    
    func removeNotifications(with identifiers: [String]) -> Promise<Void> {
        return checkAccess()
            .then { [weak self] _ -> Promise<Void> in
                guard let `self` = self else { throw NSError.cancelledError() }
                self.center.removePendingNotificationRequests(withIdentifiers: identifiers)
                self.center.removeDeliveredNotifications(withIdentifiers: identifiers)
                return Promise(value: ())
        }
    }
    
    func removeAllNotifications() -> Promise<Void> {
        return getNotifications()
            .then { [weak self] notifications -> Promise<Void> in
                guard let `self` = self else { throw NSError.cancelledError() }
                let deliveredIds = notifications.filter { $0.delivered }.map { $0.identifier }
                let pendingIds = notifications.filter { !$0.delivered }.map { $0.identifier }
                self.center.removeDeliveredNotifications(withIdentifiers: deliveredIds)
                self.center.removePendingNotificationRequests(withIdentifiers: pendingIds)
                return Promise(value: ())
        }
    }
    
    func getNotifications() -> Promise<[LocalNotification]> {
        return checkAccess()
            .then { [weak self] _ -> Promise<([LocalNotification], [LocalNotification])> in
                guard let `self` = self else { throw NSError.cancelledError() }
                return when(fulfilled: self.getPendingNotifications(), self.getDeliveredNotifications())
            }
            .then { pendingNotifications, deliveredNotifications -> Promise<[LocalNotification]> in
                return Promise(value: pendingNotifications + deliveredNotifications)
            }
            .then { [weak self] allNotifications -> [LocalNotification] in
                guard let user = self?.authManager.user else { throw NotificationManagerError.noUser }
                return allNotifications.filter { $0.userIdentifier == user.identifier }
        }
    }
    
    
    
    // MARK: - Private
    
    private func getPendingNotifications() -> Promise<[LocalNotification]> {
        return Promise(resolvers: { (fulfill, reject) in
            center.getPendingNotificationRequests(completionHandler: { [weak self] requests in
                guard let `self` = self else { return reject(NSError.cancelledError()) }
                let notifications = self.getNotifications(from: requests, delivered: false)
                fulfill(notifications)
            })
        })
    }
    
    private func getDeliveredNotifications() -> Promise<[LocalNotification]> {
        return Promise(resolvers: { (fulfill, reject) in
            center.getDeliveredNotifications { [weak self] notifications in
                guard let `self` = self else { return reject(NSError.cancelledError()) }
                let notifications = self.getNotifications(from: notifications.map { $0.request },
                                                          delivered: true)
                fulfill(notifications)
            }
        })
    }
    
    private func getNotifications(from requests: [UNNotificationRequest], delivered: Bool) -> [LocalNotification] {
        return requests.compactMap { request -> LocalNotification? in
            guard let trigger = request.trigger as? UNCalendarNotificationTrigger else {
                return nil
            }
            let dateComponents = trigger.dateComponents
            guard let date = Calendar.current.date(from: dateComponents),
                let userIdentifier = request.content.userInfo["user"] as? String else {
                return nil
            }
            return LocalNotification(identifier: request.identifier,
                                     body: request.content.body,
                                     date: date,
                                     delivered: delivered,
                                     userIdentifier: userIdentifier)
        }
    }
    
    private func registerNotification(request: UNNotificationRequest) -> Promise<Void> {
        return Promise(resolvers: { (fulfill, reject) in
            center.add(request, withCompletionHandler: { (error) in
                if let error = error {
                    reject(NotificationManagerError.notificationCenterError(error))
                    return
                }
                fulfill(())
            })
        })
    }
    
    private func checkAccess() -> Promise<Void> {
        return Promise(resolvers: { (fulfill, reject) in
            center.getNotificationSettings { (settings) in
                guard settings.authorizationStatus == .authorized else {
                    reject(NotificationManagerError.noAccess)
                    return
                }
                fulfill(())
            }
        })
    }
}



extension NotificationManagerImp: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
}


enum NotificationManagerError: Error {
    case noAccess
    case noUser
    case notificationCenterError(_ error: Error)
}

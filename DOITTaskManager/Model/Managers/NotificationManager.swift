//
//  NotificationManager.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 2/2/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

import UserNotifications
import PromiseKit

protocol NotificationManager {
    func addNotification(_ notification: LocalNotification) -> Promise<Void>
    func removeNotifications(with identifiers: [String]) -> Promise<Void>
    func removeAllNotifications() -> Promise<Void>
    func getNotifications() -> Promise<[LocalNotification]>
}


class NotificationManagerImp: NSObject, NotificationManager {
    // MARK: - Properties
    
    private let center = UNUserNotificationCenter.current()
    
    
    
    // MARK: - Init
    
    override init() {
        super.init()
        center.delegate = self
    }
    
    
    
    // MARK: - NotificationManager
    
    func addNotification(_ notification: LocalNotification) -> Promise<Void> {
        return checkAccess()
            .then { [weak self] _ -> Promise<Void> in
                guard let `self` = self else { throw NSError.cancelledError() }
                let content = UNMutableNotificationContent()
                content.title = "Reminder:"
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
        return checkAccess()
            .then { [weak self] _ -> Promise<Void> in
                guard let `self` = self else { throw NSError.cancelledError() }
                self.center.removeAllDeliveredNotifications()
                self.center.removeAllPendingNotificationRequests()
                return Promise(value: ())
        }
    }
    
    func getNotifications() -> Promise<[LocalNotification]> {
        return checkAccess()
            .then { [weak self] _ -> Promise<([LocalNotification], [LocalNotification])> in
                guard let `self` = self else { throw NSError.cancelledError() }
                return when(fulfilled: self.getPendingNotifications(), self.getDeliveredNotifications())
            }
            .then { pendingNotifications, deliveredNotifications in
                return Promise(value: pendingNotifications + deliveredNotifications)
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
            guard let date = Calendar.current.date(from: dateComponents) else {
                return nil
            }
            return LocalNotification(identifier: request.identifier,
                                     body: request.content.body,
                                     date: date,
                                     delivered: delivered)
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
    case notificationCenterError(_ error: Error)
}

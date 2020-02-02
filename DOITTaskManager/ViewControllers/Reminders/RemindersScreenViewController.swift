//
//  RemindersScreenViewController.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 2/2/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

import UIKit
import Swinject

class RemindersScreenViewController: ScreenViewController {
    // MARK: - Inner types
    
    private enum SegueIdentifier: String {
        case showLayout = "showLayout"
    }
    
    
    
    // MARK: - Properties
    
    private weak var layoutController: RemindersLayoutContoller?
    private var notificationManager: NotificationManager?
    
    
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        update()
    }
    
    override func configureNavigationBar() {
        super.configureNavigationBar()
        navigationItem.title = "Reminders"
        
        let listImage = UIImage(systemName: "trash")
        let listButton = UIBarButtonItem(image: listImage, style: .plain, target: self, action: #selector(removeAllButtonPressed))
        navigationItem.rightBarButtonItem  = listButton
    }
    
    override func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    override func setupDependencies(with resolver: Resolver) {
        super.setupDependencies(with: resolver)
        notificationManager = resolver.resolve(NotificationManager.self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        switch identifier {
        case SegueIdentifier.showLayout.rawValue:
            let layoutController = segue.destination as? RemindersLayoutContoller
            layoutController?.delegate = self
            self.layoutController = layoutController
        default:
            break
        }
    }
    
    
    
    // MARK: - Private
    
    private func update() {
        notificationManager?.getNotifications()
            .then { [weak self] notifications -> Void in
                let reminders = notifications.map { Reminder(identifier: $0.identifier, body: $0.body, date: $0.date) }
                self?.layoutController?.reminders = reminders
            }
            .catch { [weak self] error in
                self?.handleError(error)
        }
    }
    
    
    
    // MARK: - Actions
    
    @objc private func removeAllButtonPressed() {
        let primaryAction = UIAlertAction(title: "Delete all",
                                          style: .default) { [weak self] _ in
                                            self?.notificationManager?.removeAllNotifications()
                                                .then { [weak self] _ in
                                                    self?.update()
                                            }
                                            .catch { [weak self] error in
                                                self?.handleError(error)
                                            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        showError(title: "Notification",
                  message: "Are you sure you want to delete all reminders?",
                  primaryAction: primaryAction,
                  secondaryAction: cancelAction)
    }
}



extension RemindersScreenViewController: RemindersLayoutContollerDelegate {
    func layoutController(_ layoutController: RemindersLayoutContoller, didAskToRemoveReminderWith identifier: String) {
        notificationManager?.removeNotifications(with: [identifier])
            .then { [weak self] _ -> Void in
                self?.update()
            }
            .catch { [weak self] error in
                self?.handleError(error)
        }
    }
}


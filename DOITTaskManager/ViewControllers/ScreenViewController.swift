//
//  ScreenViewController.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 1/30/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

import UIKit
import Swinject

class ScreenViewController: UIViewController {
    // MARK: - Properties
    
    var hideKeyboardWhenTappedAround: Bool {
        return false
    }
    
    private let resolver = DIContainer.defaultResolver
    
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTapAroundGesture()
        setupDependencies(with: resolver)
        configureNavigationBar()
    }
    
    
    
    // MARK: - Public
    
    func setupDependencies(with resolver: Resolver) {
        
    }
    
    func configureNavigationBar() {
        navigationItem.hidesBackButton = true
        
        let backButtonImage = UIImage(systemName: "chevron.left")
        let backButton = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(backButtonPressed))
        navigationItem.leftBarButtonItem  = backButton
    }
    
    func showError(title: String = "Error!", message: String? = nil, primaryAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default, handler: nil), secondaryAction: UIAlertAction? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(primaryAction)
        alertController.preferredAction = primaryAction
        if let secondaryAction = secondaryAction {
            alertController.addAction(secondaryAction)
        }
        present(alertController, animated: true, completion: nil)
    }
    
    func showDeleteError(handler: @escaping () -> Void) {
        let primaryAction = UIAlertAction(title: "Delete",
                                          style: .default) { _ in
                                            handler()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        showError(title: "Notification",
                  message: "Are you sure you want to delete this task?",
                  primaryAction: primaryAction,
                  secondaryAction: cancelAction)
    }
    
    func handleError(_ error: Error) {
        switch error {
        case is RequestBuilderError:
            showError(message: "Request failed: Couldn't create a request!")
        case is DataManagerError:
            showError(message: "Request failed: Wrong response data!")
        case let taskManagerError as TaskManagerError:
            switch taskManagerError {
            case .failed(let errorData):
                handleApiErrorData(errorData)
            }
        case let authError as AuthError:
            switch authError {
            case .failed(let errorData):
                handleApiErrorData(errorData)
            case .noToken:
                showError(message: "Authentification failed: No token")
            }
        case let notificationError as NotificationManagerError:
            switch notificationError {
            case .notificationCenterError(let error):
                showError(message: "Notification service error: \(error)")
            case .noAccess:
                showError(message: "Notification service error: No access granted. You could change it in Settings -> Notifications")
            }
        default:
            break
        }
    }
    
    func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @discardableResult func presentViewController(withIdentifier identifier: String, storyboardIdentifier: String? = nil, fromNavigation: Bool = false) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardIdentifier ?? identifier, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: identifier)
        guard fromNavigation else {
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true, completion: nil)
            return controller
        }
        if let navigationController = navigationController {
            navigationController.pushViewController(controller, animated: true)
        }
        else {
            let navigationController = UINavigationController(rootViewController: controller)
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true)
        }
        return controller
    }
    
    
    
    // MARK: - Private
    
    private func handleApiErrorData(_ data: NSDictionary) {
        var message: String = ""
        if let messageDescription = data["message"] as? String {
            message = messageDescription
        }
        if let submessageData = data["fields"] as? [String: Any] {
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
        if message.contains("Expired token") {
            handleTokenError()
            return
        }
        showError(message: "Backend error: \(message)")
    }
    
    private func handleTokenError() {
        let primaryAction = UIAlertAction(title: "OK",
                                          style: .default) { _ in
                                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                            let controller = storyboard.instantiateViewController(withIdentifier: "Login")
                                            UIApplication.shared.keyWindow?.rootViewController = controller
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        showError(message: "Backend error: Expired token. Press OK to reload the app", primaryAction: primaryAction, secondaryAction: cancelAction)
    }
    
    private func registerTapAroundGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    
    
    // MARK: - Actions
    
    @objc private func dismissKeyboard() {
        guard hideKeyboardWhenTappedAround else { return }
        view.endEditing(true)
    }
    
    @objc private func backButtonPressed() {
        backButtonTapped()
    }
}

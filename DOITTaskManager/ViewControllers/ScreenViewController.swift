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
    }
    
    
    
    // MARK: - Public
    
    func setupDependencies(with resolver: Resolver) {
        
    }
    
    func showError(title: String = "Error!", message: String? = nil, primaryAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default, handler: nil), secondaryAction: UIAlertAction? = nil) {
        let alertController = UIAlertController(title: "Error!", message: message, preferredStyle: .alert)
        alertController.addAction(primaryAction)
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
        case let dataManagerError as DataManagerError:
            switch dataManagerError {
            case .apiError(let message):
                showError(message: "Request failed: \(message)")
            default:
                showError(message: "Request failed: Wrong response data!")
            }
        case is AuthError:
            showError(message: "Authentification failed: No token")
        default:
            break
        }
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
    
    private func registerTapAroundGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        guard hideKeyboardWhenTappedAround else { return }
        view.endEditing(true)
    }
}

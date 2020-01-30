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
    
    private let resolver = DIContainer.defaultResolver
    
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDependencies(with: resolver)
    }
    
    
    
    // MARK: - Public
    
    func setupDependencies(with resolver: Resolver) {
        
    }
    
    func showErrorMessage(_ message: String) {
        let alertController = UIAlertController(title: "Error!", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func handleError(_ error: Error) {
        switch error {
        case is RequestBuilderError:
            showErrorMessage("Request failed: Couldn't create a request!")
        case let dataManagerError as DataManagerError:
            switch dataManagerError {
            case .apiError(let message):
                showErrorMessage("Request failed: \(message)")
            default:
                showErrorMessage("Request failed: Wrong response data!")
            }
        case is AuthError:
            showErrorMessage("Authentification failed: No token")
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
}

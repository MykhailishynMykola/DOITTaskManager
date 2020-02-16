//
//  UIViewController+Convenience.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 2/16/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

import UIKit

extension UIViewController {
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

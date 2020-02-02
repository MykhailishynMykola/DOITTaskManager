//
//  LoginScreenViewController.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 1/30/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

import UIKit
import Swinject

class LoginScreenViewController: ScreenViewController {
    // MARK: - Inner types
    
    private enum SegueIdentifier: String {
        case showLayout = "showLayout"
    }
    
    
    
    // MARK: - Properties
    
    private weak var layoutController: LoginLayoutController?
    private var authManager: AuthManager?
    
    override var hideKeyboardWhenTappedAround: Bool {
        return true
    }
    
    
    
    // MARK: - Overrides
    
    override func setupDependencies(with resolver: Resolver) {
        super.setupDependencies(with: resolver)
        authManager = resolver.resolve(AuthManager.self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        switch identifier {
        case SegueIdentifier.showLayout.rawValue:
            let layoutController = segue.destination as? LoginLayoutController
            layoutController?.delegate = self
            self.layoutController = layoutController
        default:
            break
        }
    }
}



extension LoginScreenViewController: LoginLayoutControllerDelegate {
    // MARK: - LoginLayoutControllerDelegate
    
    func layoutController(_ layoutController: LoginLayoutController, didAskToLoginWithEmail email: String, password: String) {
        guard isValid(email: email, password: password) else {
            return
        }
        authManager?.login(withEmail: email, password: password)
            .then { [weak self] in
                self?.presentViewController(withIdentifier: "TaskList", fromNavigation: true)
            }
            .catch { [weak self] error in
                self?.handleError(error)
        }
    }
    
    func layoutController(_ layoutController: LoginLayoutController, didAskToRegisterWithEmail email: String, password: String, confirmPassword: String) {
        guard isValid(email: email, password: password) else {
            return
        }
        guard password == confirmPassword else {
            showError(message: "Passwords do not match!")
            return
        }
        authManager?.register(withEmail: email, password: password)
            .then { [weak self] in
                self?.presentViewController(withIdentifier: "TaskList")
            }
            .catch { [weak self] error in
                self?.handleError(error)
        }
    }
    
    
    
    // MARK: - Private
    
    private func isValid(email: String, password: String) -> Bool {
        guard isValidEmail(email) else {
            showError(message: "Invalid email!")
            return false
        }
        guard !password.isEmpty else {
            showError(message: "Password should not be empty!")
            return false
        }
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

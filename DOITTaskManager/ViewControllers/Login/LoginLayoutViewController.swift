//
//  LoginLayoutViewController.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 1/30/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

import UIKit

class LoginLayoutViewController: UIViewController, LoginLayoutController {
    // MARK: - Properties
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var confirmPasswordTextField: UITextField!
    @IBOutlet private weak var switchElement: UISwitch!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var confirmPasswordHeightConstraint: NSLayoutConstraint!
    
    
    
    // MARK: - LoginLayoutController
    
    weak var delegate: LoginLayoutControllerDelegate?
    
    func reset() {
        emailTextField.text = nil
        passwordTextField.text = nil
        confirmPasswordTextField.text = nil
        configureUI()
    }
    
    
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    
    
    // MARK: - Private
    
    private func configureUI() {
        titleLabel.text = "Sign in"
        loginButton.setTitle("LOG IN", for: .normal)
        switchElement.isOn = false
        confirmPasswordHeightConstraint.constant = 0
    }
    
    private func configureTextFields() {
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            guard let `self` = self else { return }
            self.confirmPasswordHeightConstraint.constant = self.switchElement.isOn ? 45 : 0
            self.view.layoutIfNeeded()
        })
        passwordTextField.returnKeyType = switchElement.isOn ? .next : .done
    }
    
    private func login() {
        guard switchElement.isOn else {
            delegate?.layoutController(self, didAskToLoginWithEmail: emailTextField.text ?? "", password: passwordTextField.text ?? "")
            return
        }
        delegate?.layoutController(self, didAskToRegisterWithEmail: emailTextField.text ?? "", password: passwordTextField.text ?? "", confirmPassword: confirmPasswordTextField.text ?? "")
    }
    
    
    
    // MARK: - Actions
    
    @IBAction private func loginButtonPressed(_ sender: Any) {
        login()
    }
    
    @IBAction private func switchValueChanged(_ sender: Any) {
        configureTextFields()
        guard switchElement.isOn else {
            titleLabel.text = "Sign in"
            loginButton.setTitle("LOG IN", for: .normal)
            return
        }
        titleLabel.text = "Sign up"
        loginButton.setTitle("REGISTER", for: .normal)
    }
}



extension LoginLayoutViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField where switchElement.isOn:
            confirmPasswordTextField.becomeFirstResponder()
        case passwordTextField, confirmPasswordTextField:
            login()
        default:
            break
        }
        return true
    }
}

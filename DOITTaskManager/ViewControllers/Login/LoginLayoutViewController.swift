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
    @IBOutlet private weak var switchElement: UISwitch!
    @IBOutlet private weak var loginButton: UIButton!
    
    
    
    // MARK: - LoginLayoutController
    
    weak var delegate: LoginLayoutControllerDelegate?
    
    
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    
    
    // MARK: - Private
    
    private func configureUI() {
        titleLabel.text = "Sign in"
        loginButton.titleLabel?.text = "LOG IN"
        switchElement.isOn = false
    }
    
    
    
    // MARK: - Actions
    
    @IBAction private func loginButtonPressed(_ sender: Any) {
        guard switchElement.isOn else {
            delegate?.layoutController(self, didAskToLoginWithEmail: emailTextField.text ?? "", password: passwordTextField.text ?? "")
            return
        }
        delegate?.layoutController(self, didAskToRegisterWithEmail: emailTextField.text ?? "", password: passwordTextField.text ?? "")
    }
    
    @IBAction private func switchValueChanged(_ sender: Any) {
        guard switchElement.isOn else {
            titleLabel.text = "Sign in"
            loginButton.setTitle("LOG IN", for: .normal)
            return
        }
        titleLabel.text = "Sign up"
        loginButton.setTitle("REGISTER", for: .normal)
    }
}

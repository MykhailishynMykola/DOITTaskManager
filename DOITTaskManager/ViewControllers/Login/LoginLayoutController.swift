//
//  LoginLayoutController.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 1/30/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

protocol LoginLayoutController: class {
    var delegate: LoginLayoutControllerDelegate? { get set }
}



protocol LoginLayoutControllerDelegate: class {
    func layoutController(_ layoutController: LoginLayoutController, didAskToLoginWithEmail email: String, password: String)
    func layoutController(_ layoutController: LoginLayoutController, didAskToRegisterWithEmail email: String, password: String, confirmPassword: String)
}

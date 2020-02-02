//
//  ManagersAssembly.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 1/30/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

import Swinject

final class ManagersAssembly: Assembly {
    // MARK: - Assembly
    
    func assemble(container: Container) {
        container.register(AuthManager.self) { AuthManagerImp(resolver: $0)! }
            .inObjectScope(.container)
        container.register(TaskManager.self) { TaskManagerImp(resolver: $0)! }
            .inObjectScope(.container)
        container.register(NotificationManager.self) { _ in NotificationManagerImp() }
            .inObjectScope(.container)
    }
}


//
//  DIContainer.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 1/30/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

import Swinject

/// Provides a namespace for default DI resolver. Instances of this class are useless.
final class DIContainer {
    /// Default DI resolver, used in the app.
    static private(set) var defaultResolver: Resolver = {
        let assemblies: [Assembly] = [ManagersAssembly()]
        let assembler = Assembler(assemblies)
        let resolver = (assembler.resolver as? Container)?.synchronize() ?? assembler.resolver
        return resolver
    }()
}

//
//  ResolverInitializable.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 1/30/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//


import Swinject

/// Object, which can be initialized, getting its dependencies from given resolver.
protocol ResolverInitializable {
    /// Creates a new instance of given object with given resolver used to inject dependencies.
    /// - Note: If object cannot retrieve necessary dependencies, initializer fails.
    ///
    /// - Parameter resolver: Dependencies container.
    /// - Returns: New instance with all dependencies.
    init?(resolver: Resolver)
}

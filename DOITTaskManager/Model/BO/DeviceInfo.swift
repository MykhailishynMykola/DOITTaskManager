//
//  DeviceInfo.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 1/31/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

import UIKit

struct DeviceInfo {
    // MARK: - Properties
    
    static var screenSize: CGSize {
        return UIScreen.main.bounds.size
    }
    
    static var userInterfaceIdiom: UIUserInterfaceIdiom {
        return UIDevice.current.userInterfaceIdiom
    }
    
    static var isTablet: Bool {
        return userInterfaceIdiom == .pad
    }
    
    static var isPhone: Bool {
        return userInterfaceIdiom == .phone
    }
}

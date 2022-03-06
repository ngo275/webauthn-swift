//
//  File.swift
//  
//
//  Created by Shu on 2022/03/06.
//

import UIKit

extension UIViewController {
    public func topMostViewController() -> UIViewController {
        if self.presentedViewController == nil {
            return self
        }
        if let navigation = self.presentedViewController as? UINavigationController,
            let vc = navigation.visibleViewController?.topMostViewController() {
            return vc
        }
        if let tab = self.presentedViewController as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tab.topMostViewController()
        }
        return self.presentedViewController!.topMostViewController()
    }
    
}

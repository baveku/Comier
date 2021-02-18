//
//  UINavigationController+.swift
//  Comier
//
//  Created by khoa on 18/02/2021.
//

import Foundation
import UIKit

public extension UINavigationController {
    func pushViewController(_ vc: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        pushViewController(vc, animated: animated)
        callCompletion(animated: animated, completion: completion)
    }
    
    func popViewController(animated: Bool, completion: (() -> Void)? = nil) {
        popViewController(animated: animated)
        callCompletion(animated: animated, completion: completion)
    }
    
    func popToRootViewController(animated: Bool, completion: (() -> Void)? = nil) {
        popToRootViewController(animated: animated)
        callCompletion(animated: animated, completion: completion)
    }
    
    private func callCompletion(animated: Bool, completion: (() -> Void)? = nil) {
        if animated, let coordinator = self.transitionCoordinator {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion?()
            }
        } else {
            completion?()
        }
    }
}

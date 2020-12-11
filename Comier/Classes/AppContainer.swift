//
//  AppContainer.swift
//  Comier
//
//  Created by Bách on 11/12/2020.
//

import Foundation
import Swinject

public typealias AppContainer = Container

open class COInjector: NSObject {
    public static let container = AppContainer()
    open func registerManagers() {}
    open func registerViewModels() {}
    open func registerViewControllers() {}
    
    /**
     Register Dependency With Manager: Managers. ViewModels. ViewControllers
     - Use:
        - Make Subclass from InjectManager
        - Create a Object in AppDelegate
     ~~~
     // Make Manager Object:
     let injector = COInjector()
     
     // App Delegate:
     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
     ...
     injector.configure()
     ...
     return true
     }
     ~~~
     */
    public func configure() {
        registerManagers()
        registerViewModels()
        registerViewControllers()
    }
}

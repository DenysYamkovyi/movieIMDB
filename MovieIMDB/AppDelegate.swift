//
//  AppDelegate.swift
//  MovieIMDB
//
//  Created by macbook pro on 2024-07-22.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var appCoordinator : AppCoordinator!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let mainWindow = UIWindow(frame: UIScreen.main.bounds)
        window = mainWindow
        appCoordinator = AppCoordinator(window: mainWindow)
        appCoordinator.start(animated: false)
        
        return true
    }
}

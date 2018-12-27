//
//  AppDelegate.swift
//  Parlour
//
//  Created by Ron Yi on 2018/11/27.
//  Copyright © 2018 Ron Yi. All rights reserved.
//

import UIKit
import Firebase
import MessageKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    static let applicationDidBecomeActive = "applicationDidBecomeActive"

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()

        Database.database().isPersistenceEnabled = true

        UIApplication.shared.statusBarStyle = .lightContent

        Fabric.sharedSDK().debug = true
        Fabric.with([Crashlytics.self])

        return true

    }

    func applicationWillResignActive(_ application: UIApplication) {

        NotificationCenter.default.post(Notification(name: Notification.Name("applicationDidBecomeActive")))

    }

}

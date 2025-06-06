//
//  AppDelegate.swift
//  xpyre
//
//  Created by Bella Gatzemeier on 5/21/25.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        // Override point for customization after application launch.
        return true
    }
    
    func copyJSONToDocumentsIfNeeded() {
        let fileManager = FileManager.default
        guard let bundleURL = Bundle.main.url(forResource: "LocalStorage", withExtension: "json"),
              let documentsURL = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("LocalStorage.json") else {
            print("Could not locate source or destination path")
            return
        }

        if !fileManager.fileExists(atPath: documentsURL.path) {
            do {
                try fileManager.copyItem(at: bundleURL, to: documentsURL)
                print("Copied LocalStorage.json to Documents directory")
            } catch {
                print("Failed to copy file: \(error)")
            }
        }
    }


    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


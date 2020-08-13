//
//  AppDelegate.swift
//  MyPlaces
//
//  Created by MAC on 28.07.2020.
//  Copyright © 2020 Litmax. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let schemaVersion: UInt64 = 2
        
        let config = Realm.Configuration(
            schemaVersion: schemaVersion,
            migrationBlock: { migration, oldSchemaVersion in
                if(oldSchemaVersion < schemaVersion) {
                }
        })
        
        Realm.Configuration.defaultConfiguration = config
        
        return true
    }


}


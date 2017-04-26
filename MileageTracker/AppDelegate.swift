//
//  AppDelegate.swift
//  MileageTracker
//
//  Created by Vlad Alexandru on 01/12/2016.
//  Copyright © 2016 Vlad Alexandru. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications
import Parse
import ParseFacebookUtilsV4
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate{
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let userNotificationCenter = UNUserNotificationCenter.current()
        userNotificationCenter.delegate = self
        
        userNotificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { accepted, error in
            guard accepted == true else {
                print("User declined remote notifications")
                return
            }
            application.registerForRemoteNotifications()
        }
        
        PFFacebookUtils.initializeFacebook(applicationLaunchOptions: launchOptions)
        configureRootViewController()
        Utils.showNotification(body: "didFinishLaunching")
        
        Fabric.with([Crashlytics.self])
        return true
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        Utils.showNotification(body: "willFinishLaunching")
        configureParse()
        LocationManager.startMonitoringBeacons()
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let installation = PFInstallation.current()
        installation?.setDeviceTokenFrom(deviceToken)
        installation?.saveInBackground()
    }
    // 2
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        if (error as NSError).code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
       FBSDKAppEvents.activateApp()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        Utils.showNotification(body: "willTerminate")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let aps = userInfo["aps"] as! [String: AnyObject]
        
        if aps["content-available"] as! Int == 1 {
            Utils.showNotification(body: "Silent Push Recived")
           // LocationManager.getLocationNow()
            completionHandler(.newData)
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("notification did recive")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
  
    func configureParse(){
        let configuration = ParseClientConfiguration {
            $0.applicationId = "ab4.MileageTracker"
            $0.server = "https://fierce-anchorage-90815.herokuapp.com/parse"
            $0.isLocalDatastoreEnabled = true
        }
        
        Parse.initialize(with: configuration)
        Beacon.registerSubclass()
        Location.registerSubclass()
        Trip.registerSubclass()
    }
    
    func configureRootViewController(){
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let _ = PFUser.current() {
            Beacon.queryOffline()?.countObjectsInBackground(block: { (nr, error) in
                if error == nil{
                    if nr != 0{
                        self.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "TabBarController")
                    }else{
                        let vc = storyboard.instantiateViewController(withIdentifier: "AddBeaconViewController") as! AddBeaconViewController
                        self.window?.rootViewController = vc
                    }
                }else{
                    PFUser.logOut()
                    self.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "LoginController")
                }
            })
        }else{
            window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "LoginController")
        }
    }
}

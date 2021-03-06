//
//  AppDelegate.swift
//  Example for SwiftlySalesforce
//
//  Created by Michael Epstein on 10/03/2016.
//  Copyright (c) 2016 Michael Epstein. All rights reserved.
//

import UIKit
import SwiftlySalesforce
import UserNotifications 

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, LoginDelegate {

	var window: UIWindow?
	
	/// Salesforce Connected App properties
	let consumerKey = "<YOUR SALESFORCE CONNECTED APP'S CONSUMER KEY>" // Replace with your own
	let redirectURL = URL(string: "scheme://redirect")! // Replace with your own

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		configureSalesforce(consumerKey: consumerKey, redirectURL: redirectURL)
        
        //uncomment if you want to receive push notifications, including those 
        //from salesforce's universal notification service
        //registerForRemoteNotification()
		return true
	}
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		handleRedirectURL(url: url)
		return true
	}
    
    //
    //MARK: Push notifications
    // This code below is only required if you care about push notifications.
    //
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        salesforce.registerForSalesforceNotifications(devicetoken: deviceTokenString)
            .then {
                (result) -> () in
                print("successfully registered for salesforce notifications")
            }.catch {
                error in
                print(error)
        }
    }
    
    //Called when a notification is delivered to a foreground app.
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("User Info = ",notification.request.content.userInfo)
        completionHandler([.alert, .badge, .sound])
    }
    
    //Called to let your app know which action was selected by the user for a given notification.
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("didReceive = ",response.notification.request.content.userInfo)
        
        completionHandler()
        
    }
    
    func registerForRemoteNotification() {
        if #available(iOS 10.0, *) {
            let center  = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                if error == nil{
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

}

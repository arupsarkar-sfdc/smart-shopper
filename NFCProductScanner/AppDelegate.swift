//
//  AppDelegate.swift
//  NFCProductScanner
//
//  Created by Alfian Losari on 1/26/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications
import SimpleKeychain
import Auth0
import JWTDecode

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var locationManager: CLLocationManager?
    var notificationCenter: UNUserNotificationCenter?
    let keychain = A0SimpleKeychain(service: "Auth0")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.locationManager = CLLocationManager()
        self.locationManager!.delegate = self
        
        
        
        // get the singleton object
        self.notificationCenter = UNUserNotificationCenter.current()
        
        // register as it's delegate
        notificationCenter!.delegate = self

        // define what do you need permission to use
        let options: UNAuthorizationOptions = [.alert, .sound]
        print("requesting authorization for notification.")
        // request permission
        notificationCenter!.requestAuthorization(options: options) { (granted, error) in
            if !granted {
                print("Permission not granted")
            }else {
                print("Notification Permission granted")
            }
        }
        
        return true
    }
    
    func handleEvent(forRegion region: CLRegion!) {

        // customize your notification content
        let content = UNMutableNotificationContent()
        content.title = "Geofence App"
        content.body = "Well-crafted body message"
        content.sound = UNNotificationSound.default()

        // when the notification will be triggered
        let timeInSeconds: TimeInterval = (60 * 15) // 60s * 15 = 15min
        // the actual trigger object
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInSeconds,
                                                        repeats: false)

        // notification unique identifier, for this example, same as the region to avoid duplicate notifications
        let identifier = region.identifier

        // the notification request object
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: trigger)

        // trying to add the notification request to notification center
        notificationCenter!.add(request, withCompletionHandler: { (error) in
            if error != nil {
                print("Error adding notification with identifier: \(identifier)")
            }
        })
    }

  
}


extension AppDelegate: CLLocationManagerDelegate {
    // called when user Exits a monitored region
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            print("---> user exited the region ")
            print(region)
            //let refreshToken = keychain.getEntry(forKey: "refresh_token")
            let refreshToken = keychain.string(forKey: "refresh_token")
            print(refreshToken!)
            Auth0
                .authentication()
                .renew(withRefreshToken: refreshToken!)
                .start { result in
                    switch(result) {
                    case .success(let credentials):
                        // If you have Refresh Token Rotation enabled, you get a new Refresh Token
                        // Otherwise you only get a new Access Token
                        guard let accessToken = try? credentials.accessToken,
                          let refreshToken = credentials.refreshToken else {
                            // Handle error
                            return
                        }
                        // Store the new tokens
                        print("new access token - start")
                        guard let jwt = try? decode(jwt: credentials.idToken),
                              let name = jwt.claim(name: "name").string,
                              let picture = jwt.claim(name: "picture").string else { return }
                        print("Name: \(name)")
                        print("Picture URL: \(picture)")
                        print(accessToken)
                        print("new access token - end")
                        self.keychain.setString(accessToken, forKey: "access_token")
                        self.keychain.setString(refreshToken, forKey: "refresh_token")
                    case .failure(let error):
                        print(error)
                        self.keychain.clearAll()
                        // Handle error
                    }
            }
            
            // Do what you want if this information
            self.handleEvent(forRegion: region)
        }
    }
    
    // called when user Enters a monitored region
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            print("---> user entered the region ")
            print(region)
            // Do what you want if this information
            self.handleEvent(forRegion: region)
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // when app is onpen and in foregroud
        completionHandler(.alert)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // get the notification identifier to respond accordingly
        let identifier = response.notification.request.identifier
        
        // do what you need to do
        print(identifier)
        // ...
    }
  
}



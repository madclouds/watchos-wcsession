//
//  InterfaceController.swift
//  Services Live WatchKit Extension
//
//  Created by Erik Bye on 8/15/17.
//  Copyright © 2017 Ministry Centered Technologies. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import UserNotifications


class InterfaceController: WKInterfaceController {

    var session: WCSession!
    @IBOutlet var messageLabel: WKInterfaceLabel!
    @IBOutlet var typeLabel: WKInterfaceLabel!
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.activateSession()
        self.messageLabel.setText("")
        self.typeLabel.setText("")
    }
    
    @IBAction func sendNotification() {
        self.sendMyNotification()
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
        }
    }
    
    func activateSession() {
        if WCSession.isSupported() {
            self.session = WCSession.default()
            self.session.delegate = self
            self.session.activate()
        }
    }
    
    func sendMyNotification(){
        if #available(watchOSApplicationExtension 3.0, *) {
            
            let center = UNUserNotificationCenter.current()
            UNUserNotificationCenter.current().delegate = self
            
            center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                // Enable or disable features based on authorization.
            }
            let content = UNMutableNotificationContent()
            content.title = NSString.localizedUserNotificationString(forKey: "Hello!", arguments: nil)
            content.body = NSString.localizedUserNotificationString(forKey: "Hello_message_body", arguments: nil)
            content.categoryIdentifier = "REMINDER_CATEGORY"
            // Deliver the notification in five seconds.
            let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
            let id = String(Date().timeIntervalSinceReferenceDate)
            let request = UNNotificationRequest.init(identifier: id, content: content, trigger: trigger)
            
            // Schedule the notification.
            let handler = {(error) in
                let test: String? = "Notification sent"
                self.messageLabel.setText(test)
                } as (Error?) -> Void
            
            center.add(request ,withCompletionHandler: handler)
        } else {
            // Fallback on earlier versions
        }
    }

}


extension InterfaceController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        if let message = applicationContext["message"] as? String {
            self.messageLabel.setText(message)
            self.typeLabel.setText("App Context")
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        if let message = userInfo["message"] as? String {
            self.messageLabel.setText(message)
            self.typeLabel.setText("User Info")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let message = message["message"] as? String {
            self.messageLabel.setText(message)
            self.typeLabel.setText("Send Message")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let message = message["message"] as? String {
            self.messageLabel.setText(message)
            self.typeLabel.setText("Send Message")
        }
        replyHandler(["response" : "payload"])
    }
}

extension InterfaceController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        self.messageLabel.setText("GOT A NOTIFCATION!")
        self.typeLabel.setText("Push Notification")
        completionHandler([])
    }
}

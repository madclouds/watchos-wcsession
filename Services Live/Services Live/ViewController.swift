//
//  ViewController.swift
//  Services Live
//
//  Created by Erik Bye on 8/15/17.
//  Copyright © 2017 Ministry Centered Technologies. All rights reserved.
//

import UIKit
import UserNotifications
import WatchConnectivity

class ViewController: UIViewController {
    
    var session: WCSession!
    
    lazy var stackView: UIStackView = {
       let view = UIStackView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.distribution = .fillEqually
        view.spacing = 4.0
        self.view.addSubview(view)
        self.view.addConstraint(NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0))
        return view
    }()
    
    lazy var sendMessageButton: UIButton = {
        let view = UIButton(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("Send Message", for: .normal)
        view.backgroundColor = .blue
        self.stackView.addArrangedSubview(view)
        return view
    }()
    
    lazy var applicationContextButton: UIButton = {
        let view = UIButton(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("Send Application Context", for: .normal)
        view.backgroundColor = .blue
        self.stackView.addArrangedSubview(view)
        return view
    }()
    lazy var transferUserInfoButton: UIButton = {
        let view = UIButton(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("Transfer User Info", for: .normal)
        view.backgroundColor = .blue
        self.stackView.addArrangedSubview(view)
        return view
    }()
    
    lazy var localNotificationButton: UIButton = {
        let view = UIButton(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("Send Local Notification", for: .normal)
        view.backgroundColor = .blue
        self.stackView.addArrangedSubview(view)
        return view
    }()
    
    
    override func loadView() {
        super.loadView()
        if (WCSession.isSupported()) {
            self.session = WCSession.default()
            self.session.delegate = self
            self.session.activate()
        } else {
            self.view.backgroundColor = .red
            print("Watch Connectivity isn't supported...")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = UIColor.lightGray
        self.localNotificationButton.addTarget(self, action: #selector(sendNotificationAction), for: .touchUpInside)
        self.sendMessageButton.addTarget(self, action: #selector(sendMessageAction), for: .touchUpInside)
        self.applicationContextButton.addTarget(self, action: #selector(applicationContextButtonAction), for: .touchUpInside)
        self.transferUserInfoButton.addTarget(self, action: #selector(transferUserInfoAction), for: .touchUpInside)
    }
    
    
}

//Mark: -  Actions
extension ViewController {
    
//    Use the sendMessage:replyHandler:errorHandler: or sendMessageData:replyHandler:errorHandler: method to transfer data immediately to the counterpart. These methods are intended for immediate communication when your iOS app and WatchKit extension are both active.
    func sendMessageAction() {
        if self.session.isReachable {
            self.session.sendMessage(self.createMessage(), replyHandler: { (dict) in
                print("Reply handler hit")
            }) { (error) in
                print("Error handler hit")
            }
        } else {
            print("Watch app isn't reachable")
        }
        
    }
    
//    Use the updateApplicationContext:error: method to communicate only the most recent state information to the counterpart. When the counterpart wakes, it can use this information to update its own state and remain in sync. Sending a new dictionary with this method overwrites the previous dictionary.
    func applicationContextButtonAction() {
        
        do {
            try self.session.updateApplicationContext(self.createMessage())
        } catch {
            print(error.localizedDescription)
        }
    }
    
//    Use the transferUserInfo: method to transfer a dictionary of data in the background. The dictionaries you send are queued for delivery to the counterpart and transfers continue when the current app is suspended or terminated.
    func transferUserInfoAction() {
        self.session.transferUserInfo(self.createMessage())
    }
    
    func createMessage() -> [String: Any] {
        let timeStamp = String(Date.timeIntervalSinceReferenceDate)
        let messageDict: [String: Any] = ["message": "sample payload",
                                          "time_stamp": timeStamp]
        return messageDict
    }
    
    
    func sendNotificationAction() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "Hello!", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "Hello_message_body", arguments: nil)
        content.categoryIdentifier = "REMINDER_CATEGORY"
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 5, repeats: false)
        let id = String(Date().timeIntervalSinceReferenceDate)
        let request = UNNotificationRequest.init(identifier: id, content: content, trigger: trigger)
        
        // Schedule the notification.
        
        center.add(request ,withCompletionHandler: nil)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.localNotificationButton.backgroundColor = .gray
        }) { (finished) in
            UIView.animate(withDuration: 0.5, delay: 5, options: [], animations: {
                self.localNotificationButton.backgroundColor = .blue
            }, completion: nil)
        }
        
    }
}

extension ViewController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Activation State: \(activationState)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        //no op - required
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        //no op - required
    }
}


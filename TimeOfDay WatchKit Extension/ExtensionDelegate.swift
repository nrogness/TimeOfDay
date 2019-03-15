//
//  ExtensionDelegate.swift
//  TimeOfDay WatchKit Extension
//
//  Created by Nick Rogness on 11/23/18.
//  Copyright © 2018 Rogness Software. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    var scheduledBackgroundTask = false
    
    static func scheduleComplicationUpdate() {
        let currentDate = Date()
        let scheduleDate = currentDate + TimeInterval(ComplicationController.minutesPerTimeline * 60)
        print("Scheduling background refresh task at \(currentDate) for: \(scheduleDate)")
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: scheduleDate, userInfo: nil) { (error) in
            if let err = error {
                print("Failed to schedule background refresh: \(err)")
            }
        }
    }
    
    static func reloadComplications() {
        let complicationServer = CLKComplicationServer.sharedInstance()
        guard let complications = complicationServer.activeComplications else { return }
        for complication in complications {
            print("UPDATE COMPLICATION")
            complicationServer.reloadTimeline(for: complication)
        }
    }

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        setupWatchConnectivity()
        print("ExtensionDelegate applicationDidFinishLaunching()")

    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        print("ExtensionDelegate applicationDidBecomeActive")
        
        
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
        print("ExtensionDelegate applicationWillResignActive")
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
               
                ExtensionDelegate.reloadComplications()
                
                ExtensionDelegate.scheduleComplicationUpdate()
                scheduledBackgroundTask = true
                
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                print("BACKGROUND: WKSnapshotRefreshBackgroundTask")
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                print("BACKGROUND: WKWatchConnectivityRefreshBackgroundTask")
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                print("BACKGROUND: WKURLSessionRefreshBackgroundTask")
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                print("BACKGROUND: WKRelevantShortcutRefreshBackgroundTask")
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                print("BACKGROUND: WKIntentDidRunRefreshBackgroundTask")
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                print("BACKGROUND: \(task.classForCoder.description())")
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

    func setupWatchConnectivity() {
        if WCSession.isSupported() {
            let session  = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
}

extension Notification.Name {
    static let refresh = Notification.Name("refresh")
}

extension ExtensionDelegate: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WC Session activation failed with error: \(error.localizedDescription)")
            return
        }
        
        print("WC Session activated with state: \(activationState.rawValue)")
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        if let colorName = applicationContext["TimeColor"] as? String {
            print("Watch received app context color update to: \(colorName)")
            
            updateWatch(for: colorName)
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        if let colorName = userInfo["TimeColor"] as? String {
            print("Watch received user info color update to: \(colorName)")
            updateWatch(for: colorName)
        }
    }
    
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        if let error = error {
            print("Watch failed to recieve user info transfer: \(error.localizedDescription)")
            return
        }
    }
    
    func updateWatch(for colorName:String) {
        UserDefaults.standard.set(colorName, forKey: "TimeColor")
        ExtensionDelegate.reloadComplications()
        
        NotificationCenter.default.post(name: .refresh, object: nil)
    }
    
}

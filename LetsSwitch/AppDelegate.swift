//
//  AppDelegate.swift
//  LetsSwitch
//
//  Created by Yusuke Ishihara on 2022-12-22.
//

import UIKit
import UserNotifications

class AppDelegate: UIResponder, UIApplicationDelegate {
	var scheduleVM = ScheduleViewModel()
	
	func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		return true
	}
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		Task {
			let center = UNUserNotificationCenter.current()
			center.delegate = self
			try await center.requestAuthorization(options: [.badge, .sound, .alert])
			
			await MainActor.run {
				application.registerForRemoteNotifications()
			}
		}
		
		return true
	}
	
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		let tokenRequest = Requests.buildTokenRequest(token: deviceToken)
		Task {
			try await Requests.send(request: tokenRequest)
		}
	}
	
}

extension AppDelegate: UNUserNotificationCenterDelegate {
	
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		completionHandler([.list, .sound, .banner])
	}
	
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		completionHandler()
	}
}

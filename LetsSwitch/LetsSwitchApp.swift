//
//  LetsSwitchApp.swift
//  LetsSwitch
//
//  Created by Yusuke Ishihara on 2022-12-21.
//

import SwiftUI

@main
struct LetsSwitchApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	@Environment(\.scenePhase) private var scenePhase
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.preferredColorScheme(.light)
				.environmentObject(appDelegate.scheduleVM)
		}.onChange(of: scenePhase, perform: { phase in
			if phase == .active {
				Task {
					do {
						try await appDelegate.scheduleVM.reloadSchedule()
					} catch {
						print("\(error)")
					}
				}
			}
		})
	}
	
}

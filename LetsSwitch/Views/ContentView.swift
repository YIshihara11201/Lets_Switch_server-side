//
//  ContentView.swift
//  LetsSwitch
//
//  Created by Yusuke Ishihara on 2022-12-21.
//

import SwiftUI

struct ContentView: View {
	@EnvironmentObject var scheduleVM: ScheduleViewModel
	@State private var selection = 1
	
	var body: some View {
		Timeline()
			.background(Color(red: 232/255, green: 1, blue: 213/255))
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}

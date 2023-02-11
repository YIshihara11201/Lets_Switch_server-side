//
//  TaskRegister.swift
//  LetsSwitch
//
//  Created by Yusuke Ishihara on 2022-12-22.
//

import SwiftUI

struct TaskRegister: View {
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	@EnvironmentObject var scheduleVM: ScheduleViewModel
	@State var text: String = ""
	
	let startTime: Session
	
	var body: some View {
		let slot = scheduleVM.timeslots[startTime]!
		GeometryReader {
			geometry in
			let stackHeight = geometry.size.height * 1.0
			let stackWidth = geometry.size.width
			
			VStack(alignment: .center, spacing: 0) {
				
				let startDate = startTime.dateDescription(date: Date())
				let secondsToSchedule = 60
				let deadline = Calendar.current.date(byAdding: .second, value: -secondsToSchedule, to: startDate)!
				
				if Date() > deadline {	// when register deadline is over, you cannot register
					Text("Registration has closed for \(startTime.rawValue)")
						.font(.custom("Manrope", size: 24))
				} else if slot.hasOwnTask {
					VStack(alignment: .center) {
						Text("\(startTime.rawValue)")
							.font(.custom("Manrope", size: 36))
						Text("Task")
							.font(.custom("Manrope", size: 20))
							.padding(.top, 10)
						Text("\(slot.title)")
							.font(.custom("Manrope", size: 24))
							.padding(.bottom, 30)
							.multilineTextAlignment(.center)
						
						if slot.partnerTask == nil { // when having partner, canceling task is not available
							Button(action: {
								Task {
									let timeZone = TimeZone.current.identifier
									let request = Requests.buildTaskRequest(deviceId: UniqueIdentifier.getUUID(), startTime: startTime, title: slot.title, socketId: slot.roomId, timeZone: timeZone, requestType: .delete)
									try await Requests.send(request: request)
									try await scheduleVM.reloadSchedule()
									self.presentationMode.wrappedValue.dismiss()
								}
							}, label: {
								Text("Cancel Task")
									.font(.custom("Manrope", size: 20))
							})
							.padding()
							.buttonStyle(.borderedProminent)
						}
						
					}
					.frame(height: stackHeight*0.6)
				} else {  // when you don't have a task, you can register one
					VStack(alignment: .center) {
						Text("I swear, I will start")
							.font(.custom("Manrope", size: 26))
						
						TextField("Enter task title here", text: $text)
							.font(.custom("Manrope", size: 20))
							.autocapitalization(.none)
							.textFieldStyle(RoundedBorderTextFieldStyle())
							.padding(.vertical, 15)
						Text("at \(startTime.rawValue)")
							.font(.custom("Manrope", size: 24))
						Button(action: {
							let timeZone = Calendar.current.timeZone.identifier
							let request = Requests.buildTaskRequest(deviceId: UniqueIdentifier.getUUID(), startTime: startTime, title: text, timeZone: timeZone, requestType: .create)
							Task {
								try await Requests.send(request: request)
								try await scheduleVM.reloadSchedule()
								self.presentationMode.wrappedValue.dismiss()
							}
						}, label: {
							Text("Register Task")
								.font(.custom("Manrope", size: 20))
						})
						.padding()
						.buttonStyle(.borderedProminent)
						.disabled(text.isEmpty)
					}
					.frame(height: stackHeight*0.6)
				}
			}
			.padding(.horizontal)
			.frame(width: stackWidth)
			.frame(maxHeight: stackHeight)
			.navigationBarTitle(Text("Register"), displayMode: .inline)
			.toolbarBackground(Color(red: 232/255, green: 1, blue: 213/255), for: .navigationBar)
			.scrollContentBackground(.hidden)
			.background(Color(red: 232/255, green: 1, blue: 213/255))
		}
		.frame(alignment: .center)
	}
}

struct TaskRegister_Previews: PreviewProvider {
	@State static var dummyScheduleVM = ScheduleViewModel()
	@State static var dummyText: String = "dummy"
	static let session = Session.twenty
	
	static var previews: some View {
		TaskRegister(text: dummyText, startTime: session)
			.environmentObject(dummyScheduleVM)
	}
}

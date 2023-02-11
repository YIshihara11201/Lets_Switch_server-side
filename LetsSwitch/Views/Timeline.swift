//
//  Timeline.swift
//  LetsSwitch
//
//  Created by Yusuke Ishihara on 2022-12-22.
//

import SwiftUI

struct Timeline: View {
	@EnvironmentObject var scheduleVM: ScheduleViewModel
	
	let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
	let formatter: DateFormatter = {
		var fmt = DateFormatter()
		fmt.dateFormat = "HH:mm"
		return fmt
	}()
	
	var body: some View {
		GeometryReader {
			geometry in
			HStack(alignment: .center) {
				VStack(alignment: .center) {
					NavigationView {
						List {
							Section(header: Text("Schedule")) {
								ForEach(Array(scheduleVM.timeslots.keys).sorted(by: <)) { session in
									let task = scheduleVM.timeslots[session]!
									let startDate = session.dateDescription(date: Date())
									let timeToSchedule = -1 // 1min
									let deadline = Calendar.current.date(byAdding: .minute, value: timeToSchedule, to: startDate)!
									
									if Date() > startDate {
										HStack {
											Text(String(session.rawValue))
												.font(.custom("Manrope", size: 16))
												.foregroundColor(Color.black.opacity(0.3))
										}
										.listRowBackground(Color(red: 162/255, green: 181/255, blue: 187/255))
									} else if Date() > deadline && task.hasOwnTask {
										if let roomId = task.roomId,
											 let partnerTask = task.partnerTask {
											NavigationLink(destination: MatchingRoom(session: session, roomId: roomId, taskTitle: task.title, partnerTask: partnerTask)) {
												HStack {
													Text(String(session.rawValue))
														.font(.custom("Manrope", size: 16))
													Text("Enter the waiting room")
														.font(.custom("Manrope", size: 14))
														.padding(.leading, 50)
												}
											}
											.listRowBackground(rowColor(slot: task))
										} else {
											NavigationLink(destination: MatchingRoom(session: session, taskTitle: task.title)) {
												HStack {
													Text(String(session.rawValue))
														.font(.custom("Manrope", size: 16))
													Text("Enter the waiting room")
														.font(.custom("Manrope", size: 14))
														.padding(.leading, 50)
												}
											}
											.listRowBackground(rowColor(slot: task))
										}
									} else {
										NavigationLink(destination: TaskRegister(startTime: session)) {
											HStack {
												Text(String(session.rawValue))
													.font(.custom("Manrope", size: 16))
												if task.hasOwnTask && task.hasSomebodyElse {
													Text("you have a partner")
														.font(.custom("Manrope", size: 14))
														.padding(.leading, 50)
												} else if task.hasOwnTask {
													Text("You have a task")
														.font(.custom("Manrope", size: 14))
														.padding(.leading, 50)
												} else if task.hasSomebodyElse {
													Text("Somebody will have a task")
														.font(.custom("Manrope", size: 14))
														.padding(.leading, 50)
												}
											}
										}
										.listRowBackground(rowColor(slot: task))
									}
								}
							}
							
						}
						.navigationBarTitle(Text("Schedule"), displayMode: .inline)
						.font(.custom("Manrope", size: 16))
						.scrollContentBackground(.hidden)
						.toolbarBackground(Color(red: 232/255, green: 1, blue: 213/255), for: .navigationBar)
						.background(Color(red: 232/255, green: 1, blue: 213/255))
					}
				}
			}
			.frame(width: geometry.size.width)
			.refreshable {
				Task {
					do {
						try await scheduleVM.reloadSchedule()
					} catch {
						print("\(error)")
					}
				}
			}
			.onReceive(timer) { _ in // update timeline every 30 seconds to keep application up-to-date
				Task {
					do {
						try await scheduleVM.reloadSchedule()
					} catch {
						print("\(error)")
					}
				}
			}
			
		}
	}
	
	func rowColor(slot: Timeslot) -> Color {
		var color: Color = Color(red: 137/255, green: 196/255, blue: 225/255)
		
		if !slot.hasOwnTask && slot.hasSomebodyElse {
			color = Color(red: 251/255, green: 194/255, blue: 82/255)
		} else if slot.hasOwnTask && slot.hasSomebodyElse {
			color = Color(red: 124/255, green: 209/255, blue: 184/255)
		} else if slot.hasOwnTask && !slot.hasSomebodyElse {
			color = Color(red: 255/255, green: 159/255, blue: 159/255)
		}
		
		return color
	}
}

struct TimeSlot_Previews: PreviewProvider {
	static var previews: some View {
		Timeline()
			.environmentObject(ScheduleViewModel())
	}
}

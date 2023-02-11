//
//  MatchingRoom.swift
//  LetsSwitch
//
//  Created by Yusuke Ishihara on 2022-12-22.
//

import Foundation
import SwiftUI

struct MatchingRoom: View {
	@Environment(\.scenePhase) var scenePhase
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	@EnvironmentObject var scheduleVM: ScheduleViewModel
	
	@State private var thumbsUp = 0
	@State private var timerIsActive = true
	@State private var timeRemaining: Int
	
	private var ws: WebSocketController? = nil
	private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
	
	private let session: Session
	private let taskTitle: String
	private let roomId: UUID?
	private let partnerTask: String?
	
	init(session: Session, roomId: UUID? = nil, taskTitle: String, partnerTask: String? = nil) {
		self.session = session
		self.roomId = roomId
		self.taskTitle = taskTitle
		self.partnerTask = partnerTask
		if let roomId = roomId {
			self.ws = WebSocketController(id: roomId)
		}
		
		let currDate = Date()
		_timeRemaining = State(initialValue: Int(session.dateDescription(date: currDate).timeIntervalSinceReferenceDate - currDate.timeIntervalSinceReferenceDate))
	}
	
	var body: some View {
		
		GeometryReader {
			geometry in
			let stackHeight = geometry.size.height
			let stackWidth = geometry.size.width
			
			if let partner = partnerTask {
				VStack(alignment: .center) {
					if timeRemaining > 5 {
						VStack {
							Text("You")
								.font(.custom("Manrope", size: 20))
							Text("\(taskTitle)")
								.font(.custom("Manrope", size: 28))
								.padding(.horizontal, 20)
								.multilineTextAlignment(.center)
							Text("\(timeRemaining)")
								.font(.custom("Manrope", size: 80)).monospacedDigit()
								.foregroundColor(Color(.darkGray))
								.padding(.vertical, 30)
							Text("Partner")
								.font(.custom("Manrope", size: 20))
								.padding(.top, 16)
							Text("\(partner)")
								.font(.custom("Manrope", size: 28))
								.padding(.horizontal, 20)
								.multilineTextAlignment(.center)
						}
						.frame(height: stackHeight*0.6)
					} else if timeRemaining >= 0 {
						VStack(alignment: .center) {
							Text("You")
								.font(.custom("Manrope", size: 20))
							Text("\(taskTitle)")
								.font(.custom("Manrope", size: 28))
								.padding(.top, 1)
								.padding(.horizontal, 20)
								.multilineTextAlignment(.center)
							AnimatedCountdownView(timer: timer)
								.frame(width: 200)
								.padding()
							Text("Partner")
								.font(.custom("Manrope", size: 22))
							Text("\(partner)")
								.font(.custom("Manrope", size: 28))
								.padding(.top, 1)
								.padding(.horizontal, 20)
								.multilineTextAlignment(.center)
						}
						.frame(height: stackHeight*0.6)
					} else {
						Text("Start!")
							.font(.custom("Manrope", size: 70))
							.foregroundColor(Color.pink)
					}
					
				}
				.frame(width: stackWidth, height: stackHeight)
				.toolbarBackground(Color(red: 232/255, green: 1, blue: 213/255), for: .navigationBar)
				.scrollContentBackground(.hidden)
				.background(Color(red: 232/255, green: 1, blue: 213/255))
				.navigationBarBackButtonHidden(true)
				
				ZStack {
					Button(action: {
						guard let ws = ws else { return }
						ws.sendAle()
					}, label: {
						VStack {
							Image(systemName: "hands.clap")
								.resizable()
								.frame(width: 40, height: 40)
							Text("Send Ale")
								.font(.custom("Manrope", size: 12))
								.padding(.leading, 10)
						}
					})
				}
				.foregroundColor(.blue.opacity(0.8))
				.position(CGPoint(x: 60, y: geometry.size.height-60))
				.ignoresSafeArea()
				
				ZStack {
					ForEach (0..<thumbsUp, id: \.self){ _ in
						Image(systemName: "hand.thumbsup.fill")
							.resizable()
							.frame(width: 40, height: 40)
							.modifier(ThumbsUpTapModifier())
							.padding()
					}
				}
				.foregroundColor(.red.opacity(0.8))
				.position(CGPoint(x: geometry.size.width-60, y: geometry.size.height-60))
				.ignoresSafeArea()
			} else {	// when not having a partner
				
				VStack(alignment: .center) {
					if timeRemaining > 5 {
						Text("\(taskTitle)")
							.font(.custom("Manrope", size: 32))
							.padding(.vertical, 10)
							.padding(.horizontal, 20)
							.multilineTextAlignment(.center)
						Text("will start in")
							.font(.custom("Manrope", size: 26))
						
						Text("\(timeRemaining)")
							.font(.custom("Manrope", size: 80)).monospacedDigit()
							.foregroundColor(Color(.darkGray))
							.padding(.horizontal, 20)
							.padding(.vertical, 10)
					} else if timeRemaining >= 0 {
						Text("\(taskTitle)")
							.font(.custom("Manrope", size: 32))
							.padding(.horizontal, 20)
							.padding(.vertical, 10)
						Text("will start in")
							.font(.custom("Manrope", size: 26))
						AnimatedCountdownView(timer: timer)
							.frame(width: 200, height: 200)
					}
					else {
						Text("Start!")
							.font(.custom("Manrope", size: 70))
							.foregroundColor(Color.pink)
					}
				}
				.frame(width: stackWidth, height: stackHeight)
				.toolbarBackground(Color(red: 232/255, green: 1, blue: 213/255), for: .navigationBar)
				.scrollContentBackground(.hidden)
				.background(Color(red: 232/255, green: 1, blue: 213/255))
				.navigationBarBackButtonHidden(true)
			}
		}
		.onAppear {
			guard let ws = ws else { return }
			ws.connect()
		}
		.onReceive(timer) { time in
			guard timerIsActive else { return }
			if timeRemaining >= 0 {
				timeRemaining -= 1
			} else if timeRemaining == -1 {
				Task {
					try await scheduleVM.reloadSchedule()
				}
				presentationMode.wrappedValue.dismiss()
			}
		}
		.onReceive(NotificationCenter.default.publisher(for: Notification.Name.thumbsUpReceivedNotification)) { _ in
			thumbsUpAction()
		}
		.onChange(of: scenePhase) { newPhase in
			if newPhase == .active {
				timerIsActive = true
			} else {
				timerIsActive = false
			}
		}
	}
	
	func thumbsUpAction () {
		self.thumbsUp += 1
	}
	
}

struct MatchingRoom_Previews: PreviewProvider {
	static var previews: some View {
		MatchingRoom(session: Session.eight, roomId: UUID(), taskTitle: "a dumy task", partnerTask: "help somebody")
			.environmentObject(ScheduleViewModel())
	}
}

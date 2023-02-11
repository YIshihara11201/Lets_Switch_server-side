//
//  Requests.swift
//  LetsSwitch
//
//  Created by Yusuke Ishihara on 2022-12-22.
//

import Foundation

enum TaskRequestType { case create; case delete }

struct Requests {
	
	static let tokenUrlString = "https://lets-switch-backend.herokuapp.com/token"
	static let taskUrlString = "https://lets-switch-backend.herokuapp.com/task"
	static let scheduleUrlString = "https://lets-switch-backend.herokuapp.com/schedule"

	@discardableResult
	static func send(request: URLRequest) async throws -> (Data, URLResponse) {
		let res = try await URLSession.shared.data(for: request)
		
		return res
	}
	
	static func buildTokenRequest(token: Data) -> URLRequest {
		guard let tokenUrl = URL(string: tokenUrlString) else { fatalError("Invalid URL string") }
		
		var request = URLRequest(url: tokenUrl)
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpMethod = "POST"
		request.httpBody = TokenDetails(deviceId: UniqueIdentifier.getUUID(), token: token).encoded()
		
		return request
	}
	
	static func buildTaskRequest(deviceId: String, startTime: Session, title: String, socketId: UUID?=nil, timeZone: String? = nil, requestType: TaskRequestType) -> URLRequest {
		var url: URL
		switch requestType {
		case .create:
			guard let reportUrl = URL(string: taskUrlString) else { fatalError("Invalid URL string") }
			url = reportUrl
		case .delete:
			guard let reportUrl = URL(string: taskUrlString + "/delete") else { fatalError("Invalid URL string") }
			url = reportUrl
		}
				
		var request = URLRequest(url: url)
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpMethod = "POST"
		
		if requestType == .create {
			request.httpBody = TaskDetails(date: Date().midnight(), deviceId: deviceId, startTime: startTime.rawValue, title: title, timeZone: timeZone).encoded()
		} else if requestType == .delete {
			request.httpBody = TaskDetails(date: Date().midnight(), deviceId: deviceId, startTime: startTime.rawValue, title: title, socketId: socketId!, timeZone: timeZone).encoded()
		}
		
		return request
	}
	
	static func buildScheduleRequest(date: Date) -> URLRequest {
		guard let scheduleUrl = URL(string: scheduleUrlString) else { fatalError("Invalid URL string") }
		
		var request = URLRequest(url: scheduleUrl)
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpMethod = "POST"
		request.httpBody = ScheduleRequest(deviceId: UniqueIdentifier.getUUID(), date: Date().midnight()).encoded()
	
		return request
	}
	
}

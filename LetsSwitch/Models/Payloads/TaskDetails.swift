//
//  TaskDetails.swift
//  LetsSwitch
//
//  Created by Yusuke Ishihara on 2022-12-22.
//


import Foundation

struct TaskDetails {
	private let encoder: JSONEncoder = {
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		return encoder
	}()
	
	let date: Date
	let deviceId: String
	let startTime: String
	let title: String
	let partnerTitle: String? = nil
	let isSent: Bool = false		// wether notification is sent or not
	let isPaired: Bool = false	// wether self task is paired or not
	let socketId: UUID?
	let timeZone: String?
	let debug: Bool
	
	init(date: Date, deviceId: String, startTime: String, title: String, socketId: UUID?=nil, timeZone: String?=nil) {
		self.date = date
		self.deviceId = deviceId
		self.startTime = startTime
		self.title = title
		self.socketId = socketId
		self.timeZone = timeZone
		
#if DEBUG
		encoder.outputFormatting = .prettyPrinted
		self.debug = true
#else
		self.debug = false
#endif
	}
	
	func encoded() -> Data {
		return try! encoder.encode(self)
	}
}

extension TaskDetails: Encodable {
	private enum CodingKeys: CodingKey {
		case date, deviceId, startTime, title, partnerTitle, isSent, isPaired, socketId, timeZone, debug
	}
}

extension TaskDetails: CustomStringConvertible {
	var description: String {
		return String(data: encoded(), encoding: .utf8) ?? "Invalid task"
	}
}

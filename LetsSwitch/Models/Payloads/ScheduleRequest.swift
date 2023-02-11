//
//  ScheduleRequest.swift
//  LetsSwitch
//
//  Created by Yusuke Ishihara on 2022-12-25.
//

import Foundation

struct ScheduleRequest {
	private let encoder: JSONEncoder = {
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		return encoder
	}()
	
	let deviceId: String
	let date: Date
	
	func encoded() -> Data {
		return try! encoder.encode(self)
	}
}

extension ScheduleRequest: Encodable {
	private enum CodingKeys: CodingKey {
		case deviceId, date
	}
}

extension ScheduleRequest: CustomStringConvertible {
	var description: String {
		return String(data: encoded(), encoding: .utf8) ?? "Invalid schedule"
	}
}

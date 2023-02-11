//
//  Date+Extensions.swift
//  LetsSwitch
//
//  Created by Yusuke Ishihara on 2022-12-25.
//

import Foundation

extension Date: RawRepresentable {
	private static let ios8601Formatter = ISO8601DateFormatter()
	
	public var rawValue: String {
		Date.ios8601Formatter.string(from: self)
	}
	
	public init?(rawValue: String) {
		self = Date.ios8601Formatter.date(from: rawValue) ?? Date()
	}
	
	public static func getISO8601DateString(date: Date) -> String {
		let ios = ISO8601DateFormatter()
		return ios.string(from: date)
	}
	
	public func midnight() -> Date {
		return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
	}
}

public enum Weekday: String {
	case monday, tuesday, wednesday, thursday, friday, saturday, sunday
}

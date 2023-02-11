//
//  Schedule.swift
//  LetsSwitch
//
//  Created by Yusuke Ishihara on 2022-12-25.
//

import Foundation

enum Session: String, Codable, Identifiable, CaseIterable {
	var id: RawValue { rawValue }
	case eight = "08:00", nine = "09:00", ten = "10:00", eleven = "11:00", twelve = "12:00", thirteen = "13:00", fourteen = "14:00", fifteen = "15:00", sixteen = "16:00", seventeen = "17:00", eighteen = "18:00", nineteen = "19:00", twenty = "20:00", twentyone = "21:00", twentyttwo = "22:00", twentythree = "23:00"
	
	static func < (lhs: Session, rhs: Session) -> Bool {
		return lhs.rawValue < rhs.rawValue
	}
	
	func dateDescription(date: Date) -> Date {
		switch self {
		case .eight:
			return Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: date)!
		case .nine:
			return Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: date)!
		case .ten:
			return Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: date)!
		case .eleven:
			return Calendar.current.date(bySettingHour: 11, minute: 0, second: 0, of: date)!
		case .twelve:
			return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: date)!
		case .thirteen:
			return Calendar.current.date(bySettingHour: 13, minute: 0, second: 0, of: date)!
		case .fourteen:
			return Calendar.current.date(bySettingHour: 14, minute: 0, second: 0, of: date)!
		case .fifteen:
			return Calendar.current.date(bySettingHour: 15, minute: 0, second: 0, of: date)!
		case .sixteen:
			return Calendar.current.date(bySettingHour: 16, minute: 0, second: 0, of: date)!
		case .seventeen:
			return Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: date)!
		case .eighteen:
			return Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: date)!
		case .nineteen:
			return Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: date)!
		case .twenty:
			return Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: date)!
		case .twentyone:
			return Calendar.current.date(bySettingHour: 21, minute: 0, second: 0, of: date)!
		case .twentyttwo:
			return Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: date)!
		case .twentythree:
			return Calendar.current.date(bySettingHour: 23, minute: 0, second: 0, of: date)!
		}
	}
	
}

struct Timeslot: Identifiable, Codable {
	let id: UUID
	var title: String
	var hasOwnTask: Bool
	var hasSomebodyElse: Bool
	var partnerTask: String?
	var roomId: UUID?
	
	init(id: UUID = UUID(), title: String, hasOwnTask: Bool, hasSomebodyElse: Bool) {
		self.id = id
		self.title = title
		self.hasOwnTask = hasOwnTask
		self.hasSomebodyElse = hasSomebodyElse
	}
	
	mutating func update(roomId: UUID?, partnerTask: String?) {
		self.roomId = roomId
		self.partnerTask = partnerTask
	}
	
}

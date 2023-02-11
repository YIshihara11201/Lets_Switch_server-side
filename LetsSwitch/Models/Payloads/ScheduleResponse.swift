//
//  ScheduleResponse.swift
//  LetsSwitch
//
//  Created by Yusuke Ishihara on 2022-12-26.
//

import Foundation

struct ScheduleResponse: Codable {
	let schedule: [Session: Timeslot]
	
	enum CodingKeys: CodingKey {
		case schedule
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		schedule = try container.decode([Session: Timeslot].self, forKey: .schedule)
	}
}

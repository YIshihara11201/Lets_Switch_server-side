//
//  ScheduleViewModel.swift
//  LetsSwitch
//
//  Created by Yusuke Ishihara on 2022-12-24.
//

import Foundation

final class ScheduleViewModel: ObservableObject {
	
	@Published var timeslots: [Session: Timeslot] = initializeSlots()
	static let fileName = "schedule.data"
	
	init() {
		ScheduleViewModel.load { result in
			switch result {
			case .success(let slots):
				if slots.count != 0 {
					self.timeslots = slots
				}
			case .failure(_):
				self.timeslots = ScheduleViewModel.initializeSlots()
			}
		}
	}
	
	static func initializeSlots() -> [Session: Timeslot] {
		var slots: [Session: Timeslot] = [:]
		for session in Session.allCases {
			slots[session] = Timeslot(title: "", hasOwnTask: false, hasSomebodyElse: false)
		}
		
		return slots
	}
	
	private static func fileURL(fileName: String) throws -> URL {
		try FileManager.default.url(for: .documentDirectory,
									in: .userDomainMask,
									appropriateFor: nil,
									create: true)
		.appendingPathComponent(fileName)
	}
	
	static func hasFile(fileName: String) -> Bool {
		let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
		let url = NSURL(fileURLWithPath: path)
		let fm = FileManager.default
		let pathComponent = url.appendingPathComponent("\(fileName)")!
		
		return fm.fileExists(atPath: pathComponent.path())
	}
	
	static func load(completion: @escaping (Result<[Session: Timeslot], Error>)->Void) {
		DispatchQueue.global(qos: .background).async {
			do {
				let fileURL = try fileURL(fileName: ScheduleViewModel.fileName)
				guard let file = try? FileHandle(forReadingFrom: fileURL) else {
					return
				}
				let timeslots = try JSONDecoder().decode([Session: Timeslot].self, from: file.availableData)
				DispatchQueue.main.async {
					completion(.success(timeslots))
				}
			} catch {
				DispatchQueue.main.async {
					completion(.failure(error))
				}
			}
		}
	}
	
	static func save(schedule: [Session: Timeslot], completion: @escaping (Result<Int, Error>) -> Void) {
		DispatchQueue.global(qos: .background).async {
			do {
				let outfile = try fileURL(fileName: ScheduleViewModel.fileName)
				
				let data = try JSONEncoder().encode(schedule)
				try data.write(to: outfile, options: [.atomic])
				DispatchQueue.main.async {
					completion(.success(schedule.count))
				}
			} catch {
				DispatchQueue.main.async {
					completion(.failure(error))
				}
			}
		}
	}
	
	func reloadSchedule() async throws {
		let request = Requests.buildScheduleRequest(date: Date())
		let (data, _) = try await Requests.send(request: request)
		let newSchedule = try JSONDecoder().decode(ScheduleResponse.self, from: data).schedule
		ScheduleViewModel.save(schedule: newSchedule) { saveResult in
			switch saveResult {
			case.success(_):
				ScheduleViewModel.load { loadResult in
					switch loadResult {
					case .success(let slots):
						self.timeslots = slots
					case .failure(let error):
						print("\(error)")
					}
				}
			case .failure(let error):
				print("\(error)")
			}
		}
	}
	
}

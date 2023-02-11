//
//  TokenDetails.swift
//  LetsSwitch
//
//  Created by Yusuke Ishihara on 2022-12-22.
//

import Foundation

struct TokenDetails {
	private let encoder = JSONEncoder()
	
	let deviceId: String
	let token: String
	let debug: Bool
	
	init(deviceId: String, token: Data) {
		self.deviceId = deviceId
		self.token = token.reduce("") { $0 + String(format: "%02x", $1) }
		
#if DEBUG
		encoder.outputFormatting = .prettyPrinted
		debug = true
#else
		debug = false
#endif
	}
	
	func encoded() -> Data {
		return try! encoder.encode(self)
	}
}

extension TokenDetails: Encodable {
	private enum CodingKeys: CodingKey {
		case deviceId, token, debug
	}
}

extension TokenDetails: CustomStringConvertible {
	var description: String {
		return String(data: encoded(), encoding: .utf8) ?? "Invalid token"
	}
}

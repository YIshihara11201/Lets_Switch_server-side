//
//  WebSocketTyps.swift
//  LetsSwitch
//
//  Created by Yusuke Ishihara on 2022-12-23.
//

import Foundation

enum MessageType: String, Codable {
	case handshake, ale, aleResponse
}

struct SinData: Codable {
	let type: MessageType
}

struct Handshake: Codable {
	var type = MessageType.handshake
}

struct Ale: Codable {
	var type = MessageType.ale
	var id: String
}

struct AleResponse: Codable {
	var type = MessageType.aleResponse
}

//
//  WebSocketController.swift
//  LetsSwitch
//
//  Created by Yusuke Ishihara on 2022-12-21.
//

import Foundation
import SwiftUI

final class WebSocketController {
	
	private let wsURLString = "lets-switch-backend.herokuapp.com"
	private let session: URLSession
	private let decoder = JSONDecoder()
	private let encoder = JSONEncoder()
	
	var socket: URLSessionWebSocketTask!
	var id: UUID
	
	init(id: UUID) {
		self.id = id
		self.session = URLSession(configuration: .default)
	}
	
	func connect() {
		self.socket = session.webSocketTask(with: URL(string: "ws://\(wsURLString)/socket?id=\(id)")!)
		self.listen()
		self.socket.resume()
	}
	
	func listen() {
		self.socket.receive { [weak self] (result) in
			guard let self = self else { return }
			
			switch result {
			case .failure(let error):
				print(error)
				self.socket.cancel(with: .goingAway, reason: nil)
				self.connect()
				return
			case .success(let message):
				switch message {
				case .data(let data):
					self.handle(data)
				case .string(let str):
					guard let data = str.data(using: .utf8) else { return }
					self.handle(data)
				@unknown default:
				  break
				}
			}
			self.listen()
		}
	}
	
	func handle(_ data: Data) {
		do {
			let sinData = try decoder.decode(SinData.self, from: data)
			switch sinData.type {
			case .handshake:
				print("Shook the hand")
			case .aleResponse:
				self.handleAleResponse()
			default:
				break
			}
		} catch {
			print(error)
		}
	}
	
	func handleAleResponse() {
		print("handling ale")
		DispatchQueue.main.async {
			NotificationCenter.default.post(name: Notification.Name.thumbsUpReceivedNotification, object: nil)
		}
	}
	
	func sendAle() {
		let message = Ale(id: id.uuidString)
		do {
			let data = try encoder.encode(message)
			self.socket.send(.data(data)) { (err) in
				if err != nil {
					print(err.debugDescription)
				}
			}
		} catch {
			print(error)
		}
	}
	
}

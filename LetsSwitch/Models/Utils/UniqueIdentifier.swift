//
//  UniqueIdentifier.swift
//  LetsSwitch
//
//  Created by Yusuke Ishihara on 2022-12-22.
//

import Foundation
import UIKit

struct UniqueIdentifier {
	static let uuidKey = "com.yusuke.LetsSwitch.unique_uuid"
	
	static func getUUID() -> String {
		let keychain = KeychainAccess()
		if let uuid = try? keychain.queryKeychainData(itemKey: uuidKey) {
			return uuid
		}
		let newId = UIDevice.current.identifierForVendor!.uuidString
		try? keychain.addKeychainData(itemKey: uuidKey, itemValue: newId)
		
		return newId
	}
	
	static func hasUUID() -> Bool {
	
		var key: String? = nil
		do {
			key = try KeychainAccess().queryKeychainData(itemKey: uuidKey)
		} catch {
			fatalError("\(error), \(error.localizedDescription)")
		}
		
		return key != nil
	}
	
}

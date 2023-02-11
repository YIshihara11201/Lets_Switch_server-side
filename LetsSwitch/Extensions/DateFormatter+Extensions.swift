//
//  DateFormatter+Extensions.swift
//  Let's Switch
//
//  Created by Yusuke Ishihara on 2023-02-08.
//

import Foundation

extension DateFormatter {
	static func yyyymmddFormatter() -> DateFormatter {
		let fmt = DateFormatter()
		fmt.dateFormat = "yyyy/MM/dd"
		return fmt
	}
	
	static func mmddFormatter() -> DateFormatter {
		let fmt = DateFormatter()
		fmt.dateFormat = "MM/dd"
		return fmt
	}
	
	static func hhmmFormatter() -> DateFormatter {
		let fmt = DateFormatter()
		fmt.dateFormat = "HH:mm"
		return fmt
	}
}

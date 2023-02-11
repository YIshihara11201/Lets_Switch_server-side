//
//  CountDown.swift
//  LetsSwitch
//
//  Created by Yusuke Ishihara on 2022-12-26.
//

import SwiftUI
import Combine

struct CountdownView: View {
	@Binding var countdown: CGFloat
	
	var body: some View {
		ZStack {
			Text(String(format: "%.0f", countdown))
				.font(.custom("Manrope", size: 60).monospacedDigit())
				.foregroundColor(Color(.darkGray))
				.animation(.linear(duration: 0.3))
			Circle()
				.stroke(lineWidth: 15)
				.foregroundColor(Color(.darkGray))
				.padding(10)
			Circle()
				.trim(from: 0, to: countdown / 5.0)
				.stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
				.rotation(Angle(degrees: 90))
				.rotation3DEffect(Angle(degrees: 180), axis: (x: 1, y: 0, z: 0))
				.foregroundColor(Color(red: 249/255, green: 72/255, blue: 146/255))
				.padding(10)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}

struct AnimatedCountdownView: View {
	@State var countdown: CGFloat = 5
	var timer: Publishers.Autoconnect<Timer.TimerPublisher>
	
	var body: some View {
		CountdownView(countdown: $countdown)
			.onReceive(timer) { _ in
				withAnimation(.linear(duration: 1.0)) {
					if countdown > 0 {
						countdown -= 1.0
					}
				}
			}
	}
}

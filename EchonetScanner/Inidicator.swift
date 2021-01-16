//
//  Inidicator.swift
//  EchonetScanner
//
//  Created by Katsumi Noguchi on 2021/01/15.
//  Copyright © 2021 WinDesign. All rights reserved.
//

import SwiftUI

struct LoadingIndicatorView: View {
    let isLoading: Bool
    @State private var isAnimating = false
    private let animation = Animation.linear(duration: 1).repeatForever(autoreverses: false)

    var body: some View {
        GeometryReader { geometry in
            if self.isLoading {
                Circle()
//                    .trim(from: 0, to: 0.6)
                    .stroke(AngularGradient(gradient: Gradient(colors: [.gray, .white]), center: .center),
                            style: StrokeStyle(
                                lineWidth: 4,
                                lineCap: .round,
                                dash: [0.1, 8],
                                dashPhase: 8))
                    .frame(width: 20, height: 20)
                    .rotationEffect(.degrees(self.isAnimating ? 360 : 0))
                    // アニメーションの実装
                    .onAppear() {
                        withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                            self.isAnimating = true
                        }
                    }
                    .onDisappear() {
                        self.isAnimating = false
                    }
            }
        }
    }
}


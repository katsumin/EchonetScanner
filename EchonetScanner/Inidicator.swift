//
//  Inidicator.swift
//  EchonetScanner
//
//  Created by Katsumi Noguchi on 2021/01/15.
//  Copyright © 2021 WinDesign. All rights reserved.
//

import SwiftUI

struct LoadingIndicatorView: View {
    let width: CGFloat
    let height: CGFloat
    let isLoading: Bool
    @State private var isAnimating = false
    @State private var percent = 0.0
//    private let animation = Animation.linear(duration: 1).repeatForever(autoreverses: false)

    var body: some View {
//        GeometryReader { geometry in
            if self.isLoading {
//                Circle()
////                    .trim(from: 0, to: 1.0)
//                    .stroke(AngularGradient(gradient: Gradient(colors: [.gray, .white]), center: .center),
//                            style: StrokeStyle(
//                                lineWidth: 4,
//                                lineCap: .square,
//                                dash: [0.1, 8],
//                                dashPhase: 8))
//                    .frame(width: self.width, height: self.height)
//                    .rotationEffect(.degrees(self.isAnimating ? 360 : 0))
//                    // アニメーションの実装
//                    .onAppear() {
//                        withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
//                            self.isAnimating = true
//                        }
//                    }
//                    .onDisappear() {
//                        self.isAnimating = false
//                    }
                ZStack{
//                    Circle()
//                        .foregroundColor(.white)
                    Circle()
                        .trim(from:0, to: CGFloat(100 * percent))
                        .rotation(Angle.degrees(-90))
                        .stroke(
//                            AngularGradient(gradient: Gradient(colors: [.blue, .white]), center: .center),
                            Color.blue,lineWidth: 10)
//                            style: StrokeStyle(
//                                lineWidth: 10,
//                                lineCap: .square
//                                ))
//                                lineWidth: 10,
//                                lineCap: .round,
//                                dash: [0.1, 8],
//                                dashPhase: 8))
//                        .frame(width: self.width , height: self.height )
//                        .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                }
                .frame(width: self.width, height: self.height)
            }
//        }
    }
}

#if DEBUG
struct LoadingIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingIndicatorView(width: 200, height:200, isLoading: true)
    }
}
#endif

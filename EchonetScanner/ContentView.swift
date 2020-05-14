//
//  ContentView.swift
//  EchonetScanner
//
//  Created by Katsumi Noguchi on 2020/05/12.
//  Copyright © 2020 WinDesign. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var edt = ""
    var property: EchonetNode.Property

    func captionColor(_ enable: Bool) -> Color {
        return enable ?Color.white :Color.black
    }
    func buttonColor(_ enable: Bool) -> Color {
        return enable ?Color.blue :Color.gray
    }

    var body: some View {
        VStack {
            Text("プロパティ操作")
                .font(.title)
//                .bold()
//            Spacer()
            VStack {
                HStack {
                    Text(EchonetDefine.propertyNameFromEpc(property.epc))
                        .font(.title)
                        .foregroundColor(.green)
                        .padding(.leading, 5.0)
                    Spacer()
                }
                HStack {
                    Spacer()
//                    Text(String.init(format: "EPC:%02X", property.epc))
                    Text(EchonetDefine.epcToString(property.epc))
                        .font(.subheadline)
                        .foregroundColor(.orange)
                        .padding(.trailing, 5.0)
                }
            }
            HStack {
                Text("EDT")
                    .font(.title)
                    .padding(.leading, 5.0)
                TextField("デフォルト", text: $edt)
//                    .border(Color.gray)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.title)
                    .padding(.trailing, 5.0)
            }
            HStack {
                Spacer()
                Button(action: {
                    print(self.edt)
                }){
                    Image(systemName: "square.and.arrow.down")
                    Text("Get")
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 30.0)
                .foregroundColor(captionColor(property.gettable))
                .font(.title)
                .background(buttonColor(property.gettable))
                .disabled(!property.gettable)
                .border(buttonColor(property.gettable), width: 5.0)
                .cornerRadius(10.0)
                Spacer()
                Button(action: {
                    print("tapped")
                }){
                    Image(systemName: "square.and.arrow.up")
                    Text("Set")
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 30.0)
                .foregroundColor(captionColor(property.settable))
//                    .buttonStyle(BorderlessButtonStyle())
                .font(.title)
                .background(buttonColor(property.settable))
                .disabled(!property.settable)
                .border(buttonColor(property.settable), width: 5.0)
                .cornerRadius(10.0)
                Spacer()
            }
            Spacer()
        }
    }
}

#if DEBUG
private let props = [
    EchonetNode.Property( epc: 0x80, gettable: true, settable: true ),
    EchonetNode.Property( epc: 0x8a, gettable: true, settable: false ),
]
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(property: props[0])
    }
}
#endif

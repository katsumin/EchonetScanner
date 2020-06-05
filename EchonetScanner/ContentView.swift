//
//  ContentView.swift
//  EchonetScanner
//
//  Created by Katsumi Noguchi on 2020/05/12.
//  Copyright © 2020 WinDesign. All rights reserved.
//

import SwiftUI
import ELSwift

struct ContentView: View {
    @State private var isRaw = false;
    @State private var edt = ""
    var property: EchonetNode.Property

    func captionColor(_ enable: Bool) -> Color {
        return enable ?Color.white :Color.black
    }
    func buttonColor(_ enable: Bool) -> Color {
        return enable ?Color.blue :Color.gray
    }
    func deviceType() -> String {
        return self.property.getDeviceType()
    }

    var body: some View {
        VStack {
            Text("プロパティ操作")
                .font(.title)
            VStack {
                HStack {
                    Text(EchonetDefine.propertyNameFromEpc(property.epc, property.getDeviceType()))
                        .font(.title)
                        .foregroundColor(.green)
                        .padding(.leading, 5.0)
                    Spacer()
                }
                HStack {
                    Spacer()
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
                TextField(property.getValue(isRaw), text: $edt)
//                    .border(Color.gray)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.title)
                    .padding(.trailing, 5.0)
            }
            HStack {
                Spacer()
                VStack(alignment: .center) {
                    Toggle(isOn: $isRaw) {
                        Text("")
                    }
                    .frame(width: 0.0)
                    Text("Raw Data")
                }
                Spacer()
                Button(action: {
                    print(self.edt)
                    print(self.property)
                    do {
                        try ELSwift.sendOPC1(self.property.ipAddress, [0x0e,0xf0,0x01], self.property.eoj, UInt8(ELSwift.GET), UInt8(self.property.epc), [0x00])
                    } catch let error {
                        print(error)
                    }
                }){
                    VStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Get")
                    }
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
                    VStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Set")
                    }
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
    PropertySelectable1Byte(0x80, true, true, "192.168.1.120", [0x01,0x30,0x01], [0x30],
        ["0x30": "ON", "0x31": "OFF"]),
    EchonetNode.Property(0x8a, true, false, "192.168.1.120", [0x01,0x30,0x01], Array("value8a".utf8), [:]),
]
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(property: props[0])
    }
}
#endif

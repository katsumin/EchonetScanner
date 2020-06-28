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
    @State private var isRaw = false
    @State private var edt = ""
    var property: EchonetNode.Property
    
    private func captionColor(_ enable: Bool) -> Color {
        return enable ?Color.white :Color.black
    }
    private func buttonColor(_ enable: Bool) -> Color {
        return enable ?Color.blue :Color.gray
    }
    private func deviceType() -> String {
        return self.property.getDeviceType()
    }
    private func getSelectItems(_ prop: EchonetNode.Property) -> [(String,String)] {
        var selectItems:[(String,String)] = []
        if let items = prop.selectItems {
            for pair in items.sorted(by: {$0.0 < $1.0}) {
                if isRaw {
                    selectItems.append((pair.key,pair.key))
                } else {
                    selectItems.append((pair.key,pair.value))
                }
            }
        }
        return selectItems
    }
    
    func propertyView(_ prop: EchonetNode.Property, _ selectItems: [(String,String)]) -> some View {
        HStack {
            if prop.isSelectable() {
//                Spacer()
//                Picker(selection: $edt, label:Text("EDT")
////                    .font(.title)
//                ) {
//                    ForEach(selectItems, id:\.0) { item in
//                        Text(item.1).multilineTextAlignment(.center).tag(item.0)
//                    }
//                }
////                .padding(.horizontal, 0.0)
////                .pickerStyle(SegmentedPickerStyle())
////                .pickerStyle(WheelPickerStyle())
//                Spacer()
                NavigationView {
                    Form {
                        Picker(selection: $edt, label:Text("EDT").font(.title)) {
                            ForEach(selectItems, id:\.0) { item in
                                Text(item.1).tag(item.0).font(.title)
                            }
                        }
                    }
                }
            } else {
                Text("EDT")
                    .font(.title)
                    .padding(.leading, 5.0)
                    .frame(width: 60.0)
                TextField(property.getValue(isRaw), text: $edt)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.title)
                    .padding(.trailing, 5.0)
            }
        }
        .padding([.top, .leading, .trailing], 0.0)
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
            propertyView(property, getSelectItems(property))
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
                            .padding(.all, 5.0)
                        Text("Get")
                    }
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 30.0)
                .foregroundColor(captionColor(property.gettable))
//                .font(.title)
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
                            .padding(.all, 5.0)
                        Text("Set")
                    }
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 30.0)
                .foregroundColor(captionColor(property.settable))
//                    .buttonStyle(BorderlessButtonStyle())
//                .font(.title)
                .background(buttonColor(property.settable))
                .disabled(!property.settable)
                .border(buttonColor(property.settable), width: 5.0)
                .cornerRadius(10.0)
                Spacer()
            }
            Spacer()
        }
        .padding(.top, 0.0)
        .onAppear(){
            if self.property.isSelectable() {
                self.edt = self.property.getValue(true)
            }
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

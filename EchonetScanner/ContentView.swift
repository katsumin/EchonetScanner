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
    @State private var time = Date()
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
    
    func rawPropertyView( _ prop: EchonetNode.Property) -> some View {
        Form {
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
    
    func propertyView(_ prop: EchonetNode.Property, _ selectItems: [(String,String)]) -> some View {
        HStack {
            if prop.getInputType() == EchonetNode.Property.InputType.SELECTABLE {
                NavigationView {
                    Form {
                        Picker(selection: $edt, label:Text("EDT").font(.title)) {
                            ForEach(selectItems, id:\.0) { item in
                                Text(item.1).tag(item.0).font(.title)
                            }
                        }
                    }
                }
            } else if prop.getInputType() == EchonetNode.Property.InputType.TIME_HHMM {
                if self.isRaw {
                    rawPropertyView(prop)
                } else {
                    Form {
                        DatePicker("EDT", selection: $time, displayedComponents: .hourAndMinute)
                        .onReceive([self.time].publisher.first()) { value in
                            let calendar = Calendar.current
                            let hour = calendar.component(.hour, from: value)
                            let min = calendar.component(.minute, from: value)
                            self.edt = String.init(format:"%02x%02x", hour, min)
                            print("\(hour)時\(min)分 -> \(self.edt)")
                        }
                    }
                }
            } else if prop.getInputType() == EchonetNode.Property.InputType.DATE_YYYYMMDD {
                if self.isRaw {
                    rawPropertyView(prop)
                } else {
                    Form {
                        DatePicker("EDT", selection: $time, displayedComponents: .date)
                        .onReceive([self.time].publisher.first()) { value in
                            let calendar = Calendar.current
                            let year = calendar.component(.year, from: value)
                            let month = calendar.component(.month, from: value)
                            let day = calendar.component(.day, from: value)
                            self.edt = String.init(format:"%04x%02x%02x", year, month, day)
                            print("\(year)年\(month)月\(day)日 -> \(self.edt)")
                        }
                    }
                }
            } else if prop.getInputType() == EchonetNode.Property.InputType.DEFAULT {
                rawPropertyView(prop)
            } else {
                rawPropertyView(prop)
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
                    print(self.edt)
                    print(self.property.values)
                    do {
                        let v:[UInt8] = self.property.convertValue(self.edt)
                        try ELSwift.sendOPC1(self.property.ipAddress, [0x0e,0xf0,0x01], self.property.eoj, UInt8(ELSwift.SETC), UInt8(self.property.epc), v)
                    } catch let error {
                        print(error)
                    }
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
            if self.property.getInputType() == EchonetNode.Property.InputType.SELECTABLE {
                self.edt = self.property.getValue(true)
            } else if self.property.getInputType() == EchonetNode.Property.InputType.TIME_HHMM {
                let formatter: DateFormatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                let strTime = self.property.getValue(false)
                if let d = formatter.date(from: strTime) {
                    self.time = d
                }
            } else if self.property.getInputType() == EchonetNode.Property.InputType.DATE_YYYYMMDD {
                let formatter: DateFormatter = DateFormatter()
                formatter.dateFormat = "yyyy/MM/dd"
                let strTime = self.property.getValue(false)
                if let d = formatter.date(from: strTime) {
                    self.time = d
                }
            }
        }
    }
}

#if DEBUG
private let props = [
    PropertySelectable1Byte(0x80, true, true, "192.168.1.120", [0x01,0x30,0x01], [0x30],
        ["0x30": "ON", "0x31": "OFF"]),
    EchonetNode.Property(0x8a, true, false, "192.168.1.120", [0x01,0x30,0x01], Array("value8a".utf8), [:]),
    PropertyHourMinute(0x91, true, true, "192.168.1.120", [0x01, 0x30, 0x01], [0x08, 0x00], nil),
    PropertyYearMonthDay(0x98, true, true, "192.168.1.120", [0x01, 0x30, 0x01], [0x07, 0xe4, 0x08, 0x0b], nil),
]
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(property: props[3])
    }
}
#endif

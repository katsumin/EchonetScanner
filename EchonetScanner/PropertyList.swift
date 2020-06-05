//
//  PropertyList.swift
//  EchonetScanner
//
//  Created by Katsumi Noguchi on 2020/05/14.
//  Copyright © 2020 WinDesign. All rights reserved.
//

import SwiftUI

struct PropertyList: View {
    @State private var isRaw = false
    var nodeName: String
    var properties: [EchonetNode.Property]
    
    var body: some View {
        VStack {
            NavigationView {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "doc.plaintext")
                        Text("Raw Data")
                        .fontWeight(.thin)
                        .foregroundColor(Color.blue)
                        Toggle(isOn: $isRaw) {
                            Text("")
                        }
                        .padding(.trailing)
                        .frame(width: 60.0)
                    }
                    .padding(.top, 5.0)
                    List {
                        ForEach (properties, id:\.epc) { property in
                            NavigationLink(destination: ContentView(property: property)) {
                                PropertyRow(property: property, isRaw: self.isRaw)
                            }
                            .navigationBarHidden(true)
                        }
                    }
                    .navigationBarTitle(Text(nodeName))
                }
            }
        }
    }
}

#if DEBUG
private let props = [
    PropertySelectable1Byte(0x80, true, true, "192.168.1.120", [0x01,0x30,0x01], [0x30],
        ["0x30": "ON", "0x31": "OFF"]),
    PropertyInstantPower(0x84, true, false, "192.168.1.120", [0x01,0x30,0x01], [0x00, 0x64], [:]),
    EchonetNode.Property(0xb0, true, false, "192.168.1.120", [0x01,0x30,0x01], Array("vb0".utf8), [:]),
]
struct PropertyList_Previews: PreviewProvider {
    static var previews: some View {
        PropertyList(nodeName: "低圧スマート電力量メータ", properties: props)
    }
}
#endif

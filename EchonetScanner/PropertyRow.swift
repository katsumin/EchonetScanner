//
//  PropertyRow.swift
//  EchonetScanner
//
//  Created by Katsumi Noguchi on 2020/05/13.
//  Copyright © 2020 WinDesign. All rights reserved.
//

import SwiftUI

struct PropertyRow: View {
    @State private var star = false
    var property: EchonetNode.Property
    var isRaw: Bool

    var body: some View {
        HStack {
//            Button(action: {
//                self.star.toggle()
//                print("star button")
//            }) {
//                Image(systemName: self.star ?"star.fill" :"star")
//            }
            Image(systemName: "p.circle")
                .padding(.horizontal)
                .frame(width: 30.0)
            VStack {
                HStack {
                    Text(EchonetDefine.propertyNameFromEpc(property.epc, property.getDeviceType()))
                        .foregroundColor(.green)
                        .padding(.trailing)
                    Spacer()
                    Text(property.getValue(isRaw))
                }
                HStack {
                    Text(EchonetDefine.epcToString(property.epc))
                        .foregroundColor(.orange)
                        .font(.subheadline)
                    Spacer()
                    Text("Get")
                        .foregroundColor(property.gettable ?.orange :.gray)
                        .font(.subheadline)
                    Text("Set")
                        .foregroundColor(property.settable ?.orange :.gray)
                        .font(.subheadline)
                }
            }
        }
    }
}

#if DEBUG
private let props = [
    EchonetNode.Property(0x80, true, true, "192.168.1.120", [0x01,0x30,0x01], Array("0".utf8), [:]),
    EchonetNode.Property(0x8a, true, false, "192.168.1.120", [0x01,0x30,0x01], Array("value_8a".utf8), [:]),
]
struct PropertyRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PropertyRow(property: props[0], isRaw: false)
            PropertyRow(property: props[1], isRaw: false)
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
#endif

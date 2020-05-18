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

    var body: some View {
        HStack {
            Button(action: {
                self.star.toggle()
                print("star button")
            }) {
                Image(systemName: self.star ?"star.fill" :"star")
            }
            VStack {
                HStack {
                    Text(EchonetDefine.propertyNameFromEpc(property.epc, property.deviceType))
                        .foregroundColor(.green)
                        .padding(.trailing)
                    Spacer()
                    Text(property.value)
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
    EchonetNode.Property( epc: 0x80, gettable: true, settable: true, value: "value_80", deviceType: "0x0130" ),
    EchonetNode.Property( epc: 0x8a, gettable: true, settable: false, value: "value_8a", deviceType: "0x0130" ),
]
struct PropertyRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PropertyRow(property: props[0])
            PropertyRow(property: props[1])
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
#endif

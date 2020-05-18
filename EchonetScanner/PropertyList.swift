//
//  PropertyList.swift
//  EchonetScanner
//
//  Created by Katsumi Noguchi on 2020/05/14.
//  Copyright © 2020 WinDesign. All rights reserved.
//

import SwiftUI

struct PropertyList: View {
    var nodeName: String
    var properties: [EchonetNode.Property]
    
    var body: some View {
        VStack {
//            Text(nodeName).font(.title)
//            Text("機器詳細").font(.title)
            NavigationView {
                List {
                    ForEach (properties, id:\.self) { property in
                        NavigationLink(destination: ContentView(property: property)) {
                            PropertyRow(property: property)
                        }
                    }
                }
//                .navigationBarTitle(Text("機器詳細"))
                    .navigationBarTitle(Text(nodeName))
            }
        }
    }
}

#if DEBUG
private let props = [
    EchonetNode.Property( epc: 0x80, gettable: true, settable: true, value: "v80", deviceType: "0x0130"),
    EchonetNode.Property( epc: 0x84, gettable: true, settable: false, value: "v80", deviceType: "0x0130"),
    EchonetNode.Property( epc: 0xb0, gettable: true, settable: false, value: "v80", deviceType: "0x0130"),
]
struct PropertyList_Previews: PreviewProvider {
    static var previews: some View {
        PropertyList(nodeName: "低圧スマート電力量メータ", properties: props)
    }
}
#endif

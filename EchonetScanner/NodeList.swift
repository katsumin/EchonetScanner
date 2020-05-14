//
//  NodeList.swift
//  EchonetScanner
//
//  Created by Katsumi Noguchi on 2020/05/14.
//  Copyright © 2020 WinDesign. All rights reserved.
//

import SwiftUI

struct NodeList: View {
    var nodes : [EchonetNode]
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        print("tap")
                    }){
                        Text("検索")
                    }
                    .padding(.trailing)
//                    .padding(.vertical, 10)
//                    .padding(.horizontal, 5.0)
//                    .foregroundColor(.white)
//                    .background(Color.blue)
//                    .border(Color.blue, width: 5.0)
//                    .cornerRadius(10.0)
                }
            List {
                    ForEach (nodes, id:\.self) { node in
                        NavigationLink(destination: PropertyList(nodeName: EchonetDefine.nameFromDeviceType(node.deviceType), properties: node.properties)) {
                            NodeRow(deviceType: node.deviceType, ipAddress: node.ipAddress)
                        }
                    }
                }
            }.navigationBarTitle(
                Text("Echonet機器一覧")
            )
        }
    }
}

#if DEBUG
private let props = [
    EchonetNode.Property( epc: 0x80, gettable: true, settable: true ),
    EchonetNode.Property( epc: 0x84, gettable: true, settable: false ),
    EchonetNode.Property( epc: 0x8a, gettable: true, settable: false ),
]
let nodes = [
    EchonetNode(name: "", deviceType: 0x288, ipAddress: "192.168.1.120", properties: props),
    EchonetNode(name: "", deviceType: 0x26b, ipAddress: "192.168.1.155", properties: props),
    EchonetNode(name: "", deviceType: 0x130, ipAddress: "192.168.1.158", properties: props),
]
struct NodeList_Previews: PreviewProvider {
    static var previews: some View {
        NodeList(nodes: nodes)
    }
}
#endif

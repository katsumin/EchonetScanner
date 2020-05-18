//
//  NodeList.swift
//  EchonetScanner
//
//  Created by Katsumi Noguchi on 2020/05/14.
//  Copyright © 2020 WinDesign. All rights reserved.
//

import SwiftUI
import ELSwift

private var map: [String:EchonetNode] = [:]

struct NodeList: View {
    @EnvironmentObject var userData: UserData
//    var nodes : [EchonetNode]

    private func hexString(_ data: UInt8) -> String {
        return String.init(format: "%02x", data)
    }
    private func hexString(_ dataArray: [UInt8]) -> String {
        var m = ""
        for data in dataArray {
            m.append(self.hexString(data))
        }
        return m
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        print("tap")
                        self.userData.echonetNodes.removeAll()
                        map.removeAll()
                    }){
                        Text("クリア")
                    }
                    .padding(.trailing)
                    Button(action: {
                        print("tap")
//                        self.userData.echonetNodes.removeAll()
                        ELSwift.search()
                    }){
                        Text("機器検索")
                    }
                    .padding(.trailing)
                }
            List {
                ForEach (self.userData.echonetNodes) { node in
                        NavigationLink(destination: PropertyList(nodeName: EchonetDefine.nameFromDeviceType(node.deviceType), properties: node.properties)) {
                            NodeRow(deviceType: node.deviceType, ipAddress: node.ipAddress)
                        }
                    }
                }
            }.navigationBarTitle(
                Text("Echonet機器一覧")
            )
        }.onAppear(){
            do {
                let objectList:[String] = ["05ff01"]
                try ELSwift.initialize( objectList, { rinfo, els, err in
                    if let error = err {
                        print (error)
                        return
                    }
                    
                    if let elsv = els {
                        let seoj = elsv.SEOJ
                        let esv = elsv.ESV
                        let detail = elsv.DETAIL
                        print("ip:\(rinfo.address), seoj:\(self.hexString(seoj)), esv:\(self.hexString(esv)), datail:\(self.hexString(detail))")
//                        let deviceType = Int(seoj[0]) << 8 | Int(seoj[1])
//                        let key = rinfo.address + String(format:",%04x", deviceType)
//                        if map[key] == nil {
//                            print(key)
//                            let node = EchonetNode(id: detail, deviceType: deviceType, ipAddress: rinfo.address, properties: [])
//                            self.userData.echonetNodes.append(node)
//                            map[key] = node
//                        }
                        if esv == 0x72 {
                            let deviceType = String(format:"0x%04x", Int(seoj[0]) << 8 | Int(seoj[1]))
                            let key = rinfo.address + deviceType
                            var node = map[key]
                            if node == nil {
                                node = EchonetNode.create(rinfo.address, seoj, detail)
                                map[key] = node
                                self.userData.echonetNodes.append(node!)
                            }
                            if let prop = EchonetNode.Property.parse(detail, deviceType) {
////                                var l = node!.properties
////                                l.append(prop)
////                                node!.properties = l
////                                print(l)
//                                node!.appendProperty(prop)
//                                print(self.userData.echonetNodes)
                                if let index = self.userData.echonetNodes.firstIndex(of: node!) {
                                    node!.appendProperty(prop)
                                    map[key] = node
                                    self.userData.echonetNodes[index] = node!
//                                    print(index)
                                    print(self.userData.echonetNodes)
                                }
                            }
                        }
                    }
                }, 4)
            }catch let error{
                print( error )
            }
        }
    }
}

#if DEBUG
//private let props = [
//    EchonetNode.Property( epc: 0x80, gettable: true, settable: true ),
//    EchonetNode.Property( epc: 0x84, gettable: true, settable: false ),
//    EchonetNode.Property( epc: 0x8a, gettable: true, settable: false ),
//]
//let nodes = [
//    EchonetNode(name: "", deviceType: 0x288, ipAddress: "192.168.1.120", properties: props),
//    EchonetNode(name: "", deviceType: 0x26b, ipAddress: "192.168.1.155", properties: props),
//    EchonetNode(name: "", deviceType: 0x130, ipAddress: "192.168.1.158", properties: props),
//]
struct NodeList_Previews: PreviewProvider {
    static var previews: some View {
//        NodeList(nodes: nodes).environmentObject(UserData())
        NodeList().environmentObject(UserData())
    }
}
#endif

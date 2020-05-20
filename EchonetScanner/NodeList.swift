//
//  NodeList.swift
//  EchonetScanner
//
//  Created by Katsumi Noguchi on 2020/05/14.
//  Copyright © 2020 WinDesign. All rights reserved.
//

import SwiftUI
import ELSwift

struct NodeList: View {
    @EnvironmentObject var userData: UserData

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
    private func extractNodes() -> [EchonetNode] {
//        let sortedDic = self.userData.echonetNodes.sorted(){$0.0 < $1.0}
//        print("props: \(sortedDic)")
        var l:[EchonetNode] = []
        for pair in self.userData.echonetNodes.sorted(by: {$0.0 < $1.0}) {
            for subPair in pair.value.sorted(by: {$0.0 < $1.0}) {
                l.append(subPair.value)
            }
        }
        return l
    }
    private func extractProperties(_ node:EchonetNode) -> [EchonetNode.Property] {
        let sortedDic = node.properties.sorted(){$0.0 < $1.0}
//        print("props: \(sortedDic)")
        var l:[EchonetNode.Property] = []
        for pair in sortedDic {
            l.append(pair.value)
//            print(pair.value)
        }
        return l
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        print("tap")
                        self.userData.echonetNodes.removeAll()
//                        map.removeAll()
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
                    ForEach (self.extractNodes(), id:\.self) { node in
                        NavigationLink(destination: PropertyList(nodeName: EchonetDefine.nameFromDeviceType(node.deviceType), properties: self.extractProperties(node))) {
                            NodeRow(deviceType: node.deviceType, ipAddress: node.ipAddress)
                        }
                    }
                }.navigationBarTitle(
                    Text("Echonet機器一覧")
                )
            }
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
                        if esv == ELSwift.GET_RES || esv == ELSwift.INF {
                            let opc = Int(elsv.OPC)
                            print("ip:\(rinfo.address), seoj:\(self.hexString(seoj)), esv:\(self.hexString(esv)), opc:\(opc), datail:\(self.hexString(detail))")
                            let deviceType = String(format:"0x%04x", Int(seoj[0]) << 8 | Int(seoj[1]))
                            for prop in EchonetNode.Property.parse(detail, deviceType, opc) {
                                var nodesAtAddr = self.userData.echonetNodes[rinfo.address]
                                if nodesAtAddr == nil {
                                    nodesAtAddr = [:]
                                }
                                self.userData.echonetNodes.updateValue(nodesAtAddr!, forKey: rinfo.address)
                                var node = nodesAtAddr![deviceType]
                                if node == nil {
                                    node = EchonetNode.create(rinfo.address, seoj, detail)
                                }
                                node!.appendProperty(prop)
                                self.userData.echonetNodes[rinfo.address]!.updateValue(node!, forKey: deviceType)
//                                print(self.userData.echonetNodes)
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
struct NodeList_Previews: PreviewProvider {
    static var previews: some View {
        NodeList().environmentObject(UserData())
    }
}
#endif

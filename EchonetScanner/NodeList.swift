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
    @State private var delay:Timer? = nil

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
        var l:[EchonetNode.Property] = []
        for pair in sortedDic {
            l.append(pair.value)
        }
        return l
    }
    private func getPropertyMap(prop: EchonetNode.Property) -> [UInt8]{
        var array:[UInt8] = prop.values
        if array.count >= 16 { // プロパティマップ16バイト未満は記述形式１
    //                        // 16バイト以上なので記述形式2，EPCのarrayを作り直したら，あと同じ
    //                        do {
    //                            array = try ELSwift.parseMapForm2( ELSwift.bytesToString( array ) )
    //                        }catch let error{
    //                            print( error )
    //                        }
            var val:UInt = 0x80
            var ret:[UInt8] = []
            // bit loop
            for bit:UInt8 in (0..<8) {
                // byte loop
                for byt in (1..<17) {
                    if 0x01 == ((array[byt] >> bit) & 0x01) {
                        // print("array[byt] \(array[byt]), byt \(byt), bit \(bit), val \(val)")
                        ret.append( UInt8(val) )
                    }
                    val += 1
                }
            }
            ret.insert(UInt8(ret.count), at: 0)
            array = ret
        }
//        print(array)
        return array
    }
    private func reflectSettable() {
        print("reflect settables")
        for nodes in self.userData.echonetNodes.values {
            for node in nodes.values {
                if let setProps = node.properties[0x9e] { // Setプロパティマップ
                    let array = getPropertyMap(prop: setProps)
                    
//                    var array:[UInt8] = setProps.values
//                    if( array.count >= 16 ) { // プロパティマップ16バイト未満は記述形式１
////                        // 16バイト以上なので記述形式2，EPCのarrayを作り直したら，あと同じ
////                        do {
////                            array = try ELSwift.parseMapForm2( ELSwift.bytesToString( array ) )
////                        }catch let error{
////                            print( error )
////                        }
//                        var val:UInt = 0x80
//                        var ret:[UInt8] = []
//                        // bit loop
//                        for bit:UInt8 in (0..<8) {
//                            // byte loop
//                            for byt in (1..<17) {
//                                if(  0x01  ==  ((array[byt] >> bit) & 0x01)   ) {
//                                    // print("array[byt] \(array[byt]), byt \(byt), bit \(bit), val \(val)")
//                                    ret.append( UInt8(val) )
//                                }
//                                val += 1
//                            }
//                        }
//                        ret.insert(UInt8(ret.count), at: 0)
//                        array = ret
//                    }
                    for prop in node.properties.values {
                        if array.contains(UInt8(prop.epc)) {
                            prop.settable = true
                        }
                    }
                }
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                List {
                    ForEach (self.extractNodes(), id:\.id) { node in
                        NavigationLink(destination: PropertyList(nodeName: EchonetDefine.nameFromDeviceType(node.deviceType), properties: self.extractProperties(node))) {
                            NodeRow(deviceType: node.deviceType, ipAddress: node.ipAddress)
                        }
                    .navigationBarHidden(true)
                    }
                }
                .navigationBarTitle(Text("Echonet機器一覧").font(.title), displayMode: .inline)
                .navigationBarItems(trailing:
                    HStack {
                        Spacer()
                        Button(action: {
                            ELSwift.search()
                        }){
                            Image(systemName: "arrow.clockwise")
                        }
                        .padding(.trailing)
                    }
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
                            for prop in EchonetNode.Property.parse(detail, opc, rinfo.address, seoj) {
                                var nodesAtAddr = self.userData.echonetNodes[rinfo.address]
                                if nodesAtAddr == nil {
                                    nodesAtAddr = [:]
                                }
                                self.userData.echonetNodes.updateValue(nodesAtAddr!, forKey: rinfo.address)
                                let deviceType = prop.getDeviceType()
                                var node = nodesAtAddr![deviceType]
                                if node == nil {
                                    node = EchonetNode.create(rinfo.address, seoj, detail)
                                }
                                node!.appendProperty(prop)
                                self.userData.echonetNodes[rinfo.address]!.updateValue(node!, forKey: deviceType)
                            }
                        }
                    }
                    // delayタイマ起動
                    if self.delay != nil {
                        // 動作中のタイマは止める
                        self.delay!.invalidate()
                        self.delay = nil
                    }
                    self.delay = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: {_ in
                        // 全プロパティの取得を見計らって、各プロパティのsettable値を再設定
                        self.reflectSettable()
                        // 動作中のタイマは止める
                        self.delay!.invalidate()
                        self.delay = nil
                    })
                }, 4)
            }catch let error{
                print( error )
            }
            ELSwift.search()
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

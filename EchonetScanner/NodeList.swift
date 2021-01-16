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
    @State private var withNodeProfile = false
    @State private var searchingIp = ""
    @State private var scanning = false

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
                if self.withNodeProfile || subPair.value.deviceType != 0x0ef0 {
                    l.append(subPair.value)
                }
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
        if array.count >= 16 {
            // プロパティマップ16バイト以上は記述形式２
            var val:UInt = 0x80
            var ret:[UInt8] = []
            // bit loop
            for bit:UInt8 in (0..<8) {
                // byte loop
                for byt in (1..<17) {
                    if 0x01 == ((array[byt] >> bit) & 0x01) {
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
                    for prop in node.properties.values {
                        if array.contains(UInt8(prop.epc)) && prop.selectItems != nil && !prop.selectItems!.isEmpty {
                            prop.settable = true
                        }
                    }
                }
            }
        }
    }
    private func search() -> Void {
        // すべてノードに対して，すべてのEOJをGetする
        DispatchQueue.global(qos: .background).async {
            scanning = true
            do {
//            try ELSwift.sendOPC1( ELSwift.EL_Multi, [0x0e,0xf0, 0x01], [0x0e, 0xf0, 0x01], 0x62, 0xD6, [0x00] )
                for addr in NetworkInfo.getIpAddresses() {
                    let key = NetworkInfo.toInt(addr)
                    let nodesAtAddr = self.userData.echonetNodes[key]
                    if nodesAtAddr == nil || (nodesAtAddr!.count < 2 && nodesAtAddr!["0x0ef0"] != nil) {
                        try ELSwift.sendOPC1( addr, [0x0e,0xf0, 0x01], [0x0e, 0xf0, 0x01], 0x62, 0xD6, [0x00] )
                        print(addr)
                        searchingIp = addr
                        Thread.sleep(forTimeInterval: 0.05)
                    } else {
                        print("skip: \(addr)")
                    }
                }
                searchingIp = ""
            } catch let error {
                print("Error: ELSwift.search.")
                print(error)
            }
            scanning = false
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                HStack {
                    Text(searchingIp)
                    Spacer()
                    Text("NodeProfile")
                    Toggle(isOn: $withNodeProfile){
                        Text("")
                    }
                    .padding(.trailing)
                    .frame(width: 60.0)
                }
                List {
                    ForEach (self.extractNodes(), id:\.id) { node in
                        NavigationLink(destination: PropertyList(node: node)) {
                            NodeRow(deviceType: node.deviceType, ipAddress: node.ipAddress)
                        }
//                        .navigationBarHidden(true)
                    }
                }
                .navigationBarTitle(Text("Echonet Lite 機器一覧"), displayMode: .inline)
                .navigationBarItems(trailing:
                    HStack {
                        Spacer()
                        ZStack{
                            LoadingIndicatorView(isLoading: scanning)
                            Button(action: {
                                self.search()
                            }){
                                Image(systemName: "arrow.clockwise")
                            }
                            .padding(.trailing)
                            .disabled(scanning)
                        }
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
                        let addr = rinfo.address
                        let key = NetworkInfo.toInt(addr)
                        print("key: \(key), ip:\(addr), seoj:\(self.hexString(seoj)), esv:\(self.hexString(esv)), datail:\(self.hexString(detail))")
                        if esv == ELSwift.GET_RES || esv == ELSwift.SET_RES || esv == ELSwift.INF {
                            let opc = Int(elsv.OPC)
                            print(" -> opc:\(opc)")
                            for prop in EchonetNode.Property.parse(detail, opc, addr, seoj) {
                                var nodesAtAddr = self.userData.echonetNodes[key]
                                if nodesAtAddr == nil {
                                    nodesAtAddr = [:]
                                }
                                self.userData.echonetNodes.updateValue(nodesAtAddr!, forKey: key)
                                let deviceType = prop.getDeviceType()
                                var node = nodesAtAddr![deviceType]
                                if node == nil {
                                    node = EchonetNode.create(addr, seoj, detail)
                                }
                                node!.appendProperty(prop)
                                self.userData.echonetNodes[key]!.updateValue(node!, forKey: deviceType)
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

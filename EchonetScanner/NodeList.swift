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
    private static var objectDetails: Dictionary<String, [UInt8]>!  = [String: [UInt8]]()
    @EnvironmentObject var userData: UserData
    @State private var delay:Timer? = nil
    @State private var withNodeProfile = false
//    @State private var searchingIp = ""
    @State private var scanning = false
//    @State private var stopScan = false
    @State private var percent = 0.0

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
//        print("reflect settables")
        for nodes in self.userData.echonetNodes.values {
            for node in nodes.values {
                if let setProps = node.properties[0x9e] { // Setプロパティマップ
                    let array = getPropertyMap(prop: setProps)
                    for prop in node.properties.values {
                        if array.contains(UInt8(prop.epc)) && prop.getInputType() != EchonetNode.Property.InputType.DEFAULT {
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
                var count = 0
                let size = NetworkInfo.getIpAddresses().count
                for addr in NetworkInfo.getIpAddresses() {
                    if !scanning {
//                        print("stoped")
                        break
                    }
                    let key = NetworkInfo.toInt(addr)
                    let nodesAtAddr = self.userData.echonetNodes[key]
                    if nodesAtAddr == nil || (nodesAtAddr!.count < 2 && nodesAtAddr!["0x0ef0"] != nil) {
                        try ELSwift.sendOPC1( addr, [0x0e,0xf0, 0x01], [0x0e, 0xf0, 0x01], 0x62, 0xD6, [0x00] )
//                        print(addr)
//                        DispatchQueue.main.async {
//                            searchingIp = addr
//                        }
                        Thread.sleep(forTimeInterval: 0.1)
                    } else {
//                        print("skip: \(addr)")
                    }
                    count += 1
                    DispatchQueue.main.async {
                        percent = Double(count) / Double(size)
                    }
//                    print("percent: \(percent)")
                }
            } catch let error {
                print("Error: ELSwift.search.")
                print(error)
            }
//            searchingIp = ""
            scanning = false
            DispatchQueue.main.async {
                percent = 0.0
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                HStack {
//                    Text(searchingIp)
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
                    }
                }
                .navigationBarTitle(Text("Echonet Lite 機器一覧"), displayMode: .inline)
                .navigationBarItems(trailing:
                    HStack {
                        Spacer()
                        ZStack {
//                            LoadingIndicatorView(width:20, height:20, isLoading: scanning)
//                            if scanning {
                            Circle()
                                .stroke(Color(.systemGray5),lineWidth: 2)
                                .frame(width: 30, height: 30)
                            Circle()
                                .trim(from:0, to:CGFloat(percent))
                                .rotation(Angle.degrees(-90))
                                .stroke(Color.blue,lineWidth: 2)
                                .frame(width: 30, height: 30)
//                            }
                            Button(action: {
//                                print("button")
                                if scanning {
                                    scanning = false
//                                    print("stop")
                                } else {
                                    percent = 0.0
                                    scanning = true
                                    self.search()
                                }
                            }, label: {
                                Image(systemName: scanning ?"stop.fill" :"arrow.clockwise")
                                    .frame(width: 10, height: 10)
                            })
                        }
                    }
                )
            }
        }.onAppear(){
            let objectList:[String] = ["05ff01"]
            do {
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
//                        print("key: \(key), ip:\(addr), seoj:\(self.hexString(seoj)), esv:\(self.hexString(esv)), datail:\(self.hexString(detail))")
                        if esv == ELSwift.GET {
                            if elsv.DEOJ == [0x05, 0xff, 0x01] {
                                for (key, _) in elsv.DETAILs {
                                    let epc = key
//                                    print("epc: \(epc)")
                                    do {
                                        if( NodeList.objectDetails[epc] != nil ) { // 持ってるEPCのとき
                                            try ELSwift.sendOPC1( rinfo.address, elsv.DEOJ, seoj, 0x72, ELSwift.toHexArray(epc)[0], NodeList.objectDetails[epc]! )
                                        } else { // 持っていないEPCのとき, SNA
                                            try ELSwift.sendOPC1( rinfo.address, elsv.DEOJ, seoj, 0x52, ELSwift.toHexArray(epc)[0], [0x00] )
                                        }
                                    } catch let error {
                                        print(error)
                                    }
                                }
                            }
//                            print("DEOJ: \(elsv.DEOJ), GET: \(elsv.DETAILs), OPC: \(elsv.OPC)")
                        } else if esv == ELSwift.GET_RES || esv == ELSwift.SET_RES || esv == ELSwift.INF {
                            let opc = Int(elsv.OPC)
//                            print(" -> opc:\(opc)")
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
                                if prop.eoj[0...1] == [0x0e, 0xf0] && prop.epc == 0xd6 {
                                    var instNum = prop.values[0]
                                    while( 0 < instNum ) {
                                        let begin:Int = ( Int(instNum) - 1) * 3 + 1
                                        let end:Int   = ( Int(instNum) - 1) * 3 + 4
                                        let arType = Array( prop.values[ begin..<end ] )
                                        let type = "0x" + EchonetNode.Property.hexString(Array(arType[0..<2]))
                                        var node = nodesAtAddr![type]
                                        if node == nil {
                                            node = EchonetNode.create(addr, arType, [])
                                            self.userData.echonetNodes[key]!.updateValue(node!, forKey: type)
                                        }
                                        instNum -= 1
                                    }
                                }
//                                print(self.userData.echonetNodes[key])
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
            ELSwift.Node_details["80"] = [0x30]
            ELSwift.Node_details["82"] = [0x00, 0x00, 0x48, 0x00] // EL version, 1.1
            ELSwift.Node_details["83"] = [0xfe, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00] // identifier
            ELSwift.Node_details["8a"] = [0xff, 0xff, 0xff] // maker code
            ELSwift.Node_details["9d"] = [0x02, 0x80, 0xd5]       // inf map, 1 Byte目は個数
            ELSwift.Node_details["9e"] = [0x00]                 // set map, 1 Byte目は個数
            ELSwift.Node_details["9f"] = [0x09, 0x80, 0x82, 0x83, 0x8a, 0xd3, 0xd4, 0xd5, 0xd6, 0xd7] // get map, 1 Byte目は個数
            ELSwift.Node_details["d3"] = [0x00, 0x00, 0x01]  // 自ノードで保持するインスタンスリストの総数（ノードプロファイル含まない）, user項目
            ELSwift.Node_details["d4"] = [0x00, 0x02]        // 自ノードクラス数, user項目, D4はノードプロファイルが入る
            ELSwift.Node_details["d5"] = [0x01, 0x05, 0xff, 0x01]    // インスタンスリスト通知, user項目
            ELSwift.Node_details["d6"] = ELSwift.Node_details["d5"]    // 自ノードインスタンスリストS, user項目
            ELSwift.Node_details["d7"] = [0x01, 0x05, 0xff]    // 自ノードクラスリストS, user項目
            NodeList.objectDetails["80"] = [0x30]
            NodeList.objectDetails["81"] = [0xff]
            NodeList.objectDetails["82"] = [0x00, 0x00, 0x48, 0x00] // EL version, 1.1
            NodeList.objectDetails["83"] = [0xfe, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00] // identifier
            NodeList.objectDetails["88"] = [0x42]
            NodeList.objectDetails["8a"] = [0xff, 0xff, 0xff] // maker code
            NodeList.objectDetails["9d"] = [0x02, 0x80, 0x88]
            NodeList.objectDetails["9e"] = [0x00]
            NodeList.objectDetails["9f"] = [0x09, 0x80, 0x81, 0x82, 0x83, 0x88, 0x8a, 0x9d, 0x9e, 0x9f]
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

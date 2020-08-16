//
//  PropertyList.swift
//  EchonetScanner
//
//  Created by Katsumi Noguchi on 2020/05/14.
//  Copyright © 2020 WinDesign. All rights reserved.
//

import SwiftUI
import ELSwift

struct PropertyList: View {
    @State private var isRaw = false
    var node: EchonetNode
    
    private func extractProperties(_ node:EchonetNode) -> [EchonetNode.Property] {
        let sortedDic = node.properties.sorted(){$0.0 < $1.0}
        var l:[EchonetNode.Property] = []
        for pair in sortedDic {
            l.append(pair.value)
        }
        return l
    }
    
    private func regetProperty(_ node:EchonetNode, _ epc:UInt8, _ deoj:[UInt8]) {
        if let p = self.node.properties[Int(epc)] {
//            print(p)
            // 取得済みのプロパティはスキップ
            return
        }
//        print(epc)
        do {
            try ELSwift.sendOPC1( self.node.ipAddress, [0x0e, 0xf0, 0x01], deoj, 0x62, epc, [0x00] )
        } catch let error {
            print( error )
        }
    }

    var body: some View {
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
                    ForEach (self.extractProperties(node), id:\.epc) { property in
                        HStack {
                            NavigationLink(destination: ContentView(property: property)) {
                                PropertyRow(property: property, isRaw: self.isRaw)
                            }
                            .navigationBarHidden(true)
                        }
                    }
                }
                .navigationBarTitle(Text(EchonetDefine.nameFromDeviceType(node.deviceType)), displayMode:.inline)
                .navigationBarItems(trailing:
                    HStack {
                        Spacer()
                        Button(action: {
                            // 未取得のプロパティを取り直す
                            if let propMapGet = self.node.properties[0x9f] {
                                var array = propMapGet.values
                                do {
                                    if( array.count >= 16 ) {
                                        // 16バイト以上なので記述形式2，EPCのarrayを作り直したら，あと同じ
                                        array = try ELSwift.parseMapForm2( ELSwift.bytesToString( propMapGet.values ) )
                                    }
                                    let num = array[0]
                                    for i:UInt8 in (0..<num ) {
                                        let epc = array[Int(i+1)]
                                        if epc != 0x9f {
                                            // このとき9fをまた取りに行くと無限ループなのでやめる
                                            self.regetProperty(self.node, epc, propMapGet.eoj)
                                        }
                                    }
                                } catch let error {
                                    print(error)
                                }
                            } else {
                                self.regetProperty(self.node, 0x9f, self.node.eoj)
                            }
                        }){
                            Image(systemName: "arrow.clockwise")
                        }
                        .padding(.trailing)
                    }
                )
            }
        }
    }
}

#if DEBUG
private var node = EchonetNode(deviceType: 0x0130, ipAddress: "192.168.1.120", properties: [
    0x80: PropertySelectable1Byte(0x80, true, true, "192.168.1.120", [0x01,0x30,0x01], [0x30],["0x30": "ON", "0x31": "OFF"]),
    0x84: PropertyInstantPower(0x84, true, false, "192.168.1.120", [0x01,0x30,0x01], [0x00, 0x64], [:]),
    0xb0: EchonetNode.Property(0xb0, true, false, "192.168.1.120", [0x01,0x30,0x01], Array("vb0".utf8), [:]),
], eoj: [0x01,0x30,0x01])
struct PropertyList_Previews: PreviewProvider {
    static var previews: some View {
        PropertyList(node: node)
    }
}
#endif

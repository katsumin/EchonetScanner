//
//  EchonetNode.swift
//  EchonetScanner
//
//  Created by Katsumi Noguchi on 2020/05/12.
//  Copyright © 2020 WinDesign. All rights reserved.
//

//import UIKit
//import CoreLocation
import Foundation

var echonetNodeDatas: [String:[String:EchonetNode]] = [:]

struct EchonetNode: Hashable, Codable, Identifiable {
    var id: [UInt8]
//    var name: String
    var deviceType: Int
    var ipAddress: String
//    var category: Category
//
//    enum Category: String, CaseIterable, Codable, Hashable {
//        case featured = "Featured"
//        case lakes = "Lakes"
//        case rivers = "Rivers"
//        case mountains = "Mountains"
//    }
    // プロパティリスト
    var properties:[Int:Property] = [:]

    mutating func appendProperty(_ prop: Property) -> Void {
        self.properties.updateValue(prop, forKey:prop.epc)
    }

    // プロパティ定義
    struct Property: Hashable, Codable {
        var epc: Int
//        var name: String
        var gettable: Bool
        var settable: Bool
//        var parent: EchonetNode
        var value: String
        var deviceType: String

        static private func hexString(_ data: UInt8) -> String {
            return String.init(format: "%02x", data)
        }
        static private func hexString(_ dataArray: [UInt8]) -> String {
            var m = ""
            for data in dataArray {
                m.append(self.hexString(data))
            }
            return m
        }

        static func parse(_ detail:[UInt8], _ deviceType: String, _ opc: Int) -> [Property] {
            var l:[Property] = []
//            print(detail[0])
//            if detail[0] == 0x80 {
//                return Property(epc: Int(detail[0]), gettable: true, settable: false)
//            }
//            return nil
//            return Property(epc: Int(detail[0 + offset]), gettable: true, settable: false, value: hexString(detail), deviceType: deviceType)
            var offset = 0
            for _ in 0..<opc {
                let epc = Int(detail[0+offset])
                let len = Int(detail[1+offset])
                let value = detail[2+offset ..< 2+offset+len]
                var m = ""
                for v in value {
                    m.append(self.hexString(v))
                }
                let prop = Property(epc: epc, gettable: true, settable: false, value: m, deviceType: deviceType)
                l.append(prop)
                offset += len + 2
            }
            return l
        }
    }
    
    static private var keys:[String] = []
    static func create(_ ipAddress:String, _ seoj:[UInt8], _ detail:[UInt8]) -> EchonetNode {
        let deviceType = Int(seoj[0]) << 8 | Int(seoj[1])
        let key = ipAddress + String(format:",%04x", deviceType)
//        if !keys.contains(key) {
//            keys.append(key)
//            var node = EchonetNode(id: [UInt8](key.data(using: .utf8)!), deviceType: deviceType, ipAddress: ipAddress, properties: [])
////            if let prop = Property.parse(detail) {
////                node.properties.append(prop)
////                print(prop)
////            }
//            return node
//        }
//        return nil
        return EchonetNode(id: [UInt8](key.data(using: .utf8)!), deviceType: deviceType, ipAddress: ipAddress)
    }
    
    static func clear() -> Void {
        keys.removeAll()
        echonetNodeDatas.removeAll()
    }
}

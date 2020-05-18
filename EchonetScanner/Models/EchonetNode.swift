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

var echonetNodeDatas:[EchonetNode] = []

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
    var properties:[Property]

    mutating func appendProperty(_ prop: Property) -> Void {
        if !self.properties.contains(prop) {
            self.properties.append(prop)
        }
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

        static func parse(_ detail:[UInt8], _ deviceType: String) -> Property? {
//            print(detail[0])
//            if detail[0] == 0x80 {
//                return Property(epc: Int(detail[0]), gettable: true, settable: false)
//            }
//            return nil
            return Property(epc: Int(detail[0]), gettable: true, settable: false, value: hexString(detail), deviceType: deviceType)
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
        return EchonetNode(id: [UInt8](key.data(using: .utf8)!), deviceType: deviceType, ipAddress: ipAddress, properties: [])
    }
    
    static func clear() -> Void {
        keys.removeAll()
        echonetNodeDatas.removeAll()
    }
}

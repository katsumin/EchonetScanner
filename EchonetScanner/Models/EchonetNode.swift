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

struct EchonetNode {
    var id:String
    var deviceType: Int
    var ipAddress: String
    // プロパティリスト
    var properties:[Int:Property]
    
    init(deviceType:Int, ipAddress:String, properties:[Int:Property]) {
        self.deviceType = deviceType
        self.ipAddress = ipAddress
        self.id = ipAddress + String(deviceType, radix: 16)
        self.properties = properties
    }

    mutating func appendProperty(_ prop: Property) -> Void {
        self.properties.updateValue(prop, forKey:prop.epc)
    }

    // プロパティ定義
    class Property {
        var epc: Int
        var gettable: Bool
        var settable: Bool
        var ipAddress: String
        var eoj: [UInt8]
        var values: [UInt8]
        var selectItems: [String:String]?

        required init(_ epc:Int, _ gettable:Bool, _ settable:Bool, _ ipAddress:String, _ eoj:[UInt8], _ values:[UInt8], _ selectItems: [String:String]?){
            self.epc = epc
            self.gettable = gettable
            self.settable = settable
            self.values = values
            self.ipAddress = ipAddress
            self.eoj = eoj
            self.selectItems = selectItems
        }

        static internal func hexString(_ data: UInt8) -> String {
            return String.init(format: "%02x", data)
        }
        static internal func hexString(_ dataArray: [UInt8]) -> String {
            var m = ""
            for data in dataArray {
                m.append(self.hexString(data))
            }
            return m
        }

        static func parse(_ detail:[UInt8], _ opc: Int, _ ipAddress: String, _ eoj: [UInt8]) -> [Property] {
            var l:[Property] = []
            var offset = 0
            for _ in 0..<opc {
                let epc = Int(detail[0+offset])
                let len = Int(detail[1+offset])
                let deviceType = "0x" + Property.hexString(Array(eoj[0..<2]))
                let strEpc = String.init(format: "0x%02x", epc)
                var prop:PropertyDefine? = nil
                if let device = echonetDefine.properties[deviceType] {
                    prop = device[strEpc]
                }
                if prop == nil {
                    prop = echonetDefine.properties["super"]![strEpc]
                }
                if prop != nil {
                    let selectItems = prop!.select_items
                    if let className = prop!.class_name {
                        let clazz = NSClassFromString("EchonetScanner.\(className)") as! EchonetNode.Property.Type
                        let p = clazz.init(epc, true, false, ipAddress, eoj, Array(detail[2+offset ..< 2+offset+len]), selectItems)
                        l.append(p)
                    } else {
                        l.append(Property(epc, true, false, ipAddress, eoj, Array(detail[2+offset ..< 2+offset+len]), selectItems))
                    }
                } else {
                    l.append(Property(epc, true, false, ipAddress, eoj, Array(detail[2+offset ..< 2+offset+len]), nil))
                }
                offset += len + 2
            }
            return l
        }
        
        func getDeviceType() -> String {
            return "0x" + Property.hexString(Array(self.eoj[0..<2]))
        }

        func getValue(_ raw: Bool) -> String {
            if values.count == 0 {
                return "unknown"
            }
            return EchonetNode.Property.hexString(values)
        }
        
        func convertValue(_ edt: String) -> [UInt8] {
            return hexString2ByteArray(edt, 0, edt.count)
        }
        
        func getInputType() -> InputType {
            return InputType.DEFAULT
        }
        
        func hexString2ByteArray(_ str: String, _ start:Int, _ end:Int) -> [UInt8] {
            var array:[UInt8] = []
            let mod = end % 2
            for i in stride(from:start, to:end - mod, by:2) {
                let d = String(str[str.index(str.startIndex, offsetBy:i)..<str.index(str.startIndex, offsetBy: i+2)])
                array.append(UInt8(d, radix: 16)!)
            }
            print(array)
            return array
        }
        
        enum InputType {
            case DEFAULT
            case SELECTABLE
            case DATE_YYYYMMDD
            case TIME_HHMM
        }
    }
    
    static func create(_ ipAddress:String, _ seoj:[UInt8], _ detail:[UInt8]) -> EchonetNode {
        let deviceType = Int(seoj[0]) << 8 | Int(seoj[1])
        return EchonetNode(deviceType: deviceType, ipAddress: ipAddress, properties: [:])
    }
    
    static func clear() -> Void {
        echonetNodeDatas.removeAll()
    }
}

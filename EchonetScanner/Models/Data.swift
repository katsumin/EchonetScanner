//
//  Data.swift
//  EchonetScanner
//
//  Created by Katsumi Noguchi on 2020/05/12.
//  Copyright © 2020 WinDesign. All rights reserved.
//

import Foundation

let echonetDefine :EchonetDefine = load("EchonetDefine.json")
func load<T: Decodable>(_ filename: String) -> T {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}

struct EchonetDefine :Decodable {
    var device_types : Dictionary<String, DeviceDefine>
    var properties: Dictionary<String, Dictionary<String, PropertyDefine>>
    
    static func propertyNameFromEpc(_ epc: Int, _ deviceType: String) -> String {
        if let defineAtDeviceType = echonetDefine.properties[deviceType] {
            if let dataAtEpc = defineAtDeviceType[epcToString(epc)] {
                return dataAtEpc.name
            }
        }
        if let dataAtEpc = echonetDefine.properties["super"]![epcToString(epc)] {
            return dataAtEpc.name
        }
        return "unknown"
    }
    
    static func epcToString(_ epc: Int) -> String {
        return String.init(format:"0x%02x", epc)
    }
    
    static func nameFromDeviceType(_ deviceType: Int) -> String {
        if let device = echonetDefine.device_types[deviceTypeToString(deviceType)] {
            return device.name
        }
        return "unknown"
    }
    
    static func iconFromDevieType(_ deviceType: Int) -> String {
        if let device = echonetDefine.device_types[deviceTypeToString(deviceType)], let icon = device.icon_name {
            return icon
        }
        return "star"
    }
    
    static func iconRotateFromDevieType(_ deviceType: Int) -> Double {
        if let device = echonetDefine.device_types[deviceTypeToString(deviceType)], let rotate = device.icon_rotate {
            return rotate
        }
        return 0
    }
    
    static func deviceTypeToString(_ deviceType: Int) -> String {
        return String.init(format:"0x%04x", deviceType)
    }
}

struct PropertyDefine: Decodable {
    var name: String
    var type: String
    var select_items : [String:String]?
    var class_name : String?
}

struct DeviceDefine: Decodable {
    var name: String
    var icon_name: String?
    var icon_rotate: Double?
}

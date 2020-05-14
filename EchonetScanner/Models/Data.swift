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
    var device_types : Dictionary<String, String>
    var properties: Dictionary<String,Dictionary<String,Dictionary<String,String>>>
    
    static func propertyNameFromEpc(_ epc: Int) -> String {
        var propName = "unknown"
        if let dataAtEpc = echonetDefine.properties["super"]![epcToString(epc)] {
            propName = dataAtEpc["name"]!
//            print(dataAtEpc)
        }
        return propName
    }
    
    static func epcToString(_ epc: Int) -> String {
        return String.init(format:"0x%02x", epc)
    }
    
    static func nameFromDeviceType(_ deviceType: Int) -> String {
        guard let name = echonetDefine.device_types[deviceTypeToString(deviceType)] else {
            return "unknown"
        }
        return name
    }
    
    static func deviceTypeToString(_ deviceType: Int) -> String {
        return String.init(format:"0x%04x", deviceType)
    }
}
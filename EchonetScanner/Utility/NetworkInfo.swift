//
//  NetworkInfo.swift
//  EchonetScanner
//
//  Created by Katsumi Noguchi on 2021/01/11.
//  Copyright © 2021 WinDesign. All rights reserved.
//

import Foundation
//import Darwin

class NetworkInfo {
    public static func toInt(_ ipAddrStr:String) -> UInt32 {
        var i:UInt32 = 0
        let bytes = ipAddrStr.split(separator: ".")
        for b in bytes {
            i <<= 8
            i = i | UInt32(b)!
        }
        return i
    }
//    private static func toBinary(_ ipAddrStr:String) -> [UInt8] {
//        var addr:[UInt8] = []
//        let bytes = ipAddrStr.split(separator: ".")
//        for b in bytes {
//            addr.append(UInt8(b)!)
//        }
//        return addr
//    }
    private static func toString(_ ipAddrInt:UInt32) -> String {
        var addr:[UInt8] = [0, 0, 0, 0]
        var a = ipAddrInt
        for i in (0..<4) {
//            print(String(format:"%08x", a))
            addr[3 - i] = UInt8(a & 255)
            a >>= 8
        }
//        print(addr)
        return String(format:"%d.%d.%d.%d", addr[0], addr[1], addr[2], addr[3])
    }

    public static func getIpAddresses() -> [String] {
        var addesses:[String] = []

        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return addesses }
        guard let firstAddr = ifaddr else { return addesses }

        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
//            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
            // Check for IPv4:
            if addrFamily == UInt8(AF_INET) {
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    // Convert interface address to a human readable string:
                    var addr = interface.ifa_addr.pointee
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                    var netmask = interface.ifa_netmask.pointee
                    var mask = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(&netmask, socklen_t(netmask.sa_len), &mask, socklen_t(mask.count), nil, socklen_t(0), NI_NUMERICHOST)
                    let addressTemp = String(cString: hostname)
                    let subnet = String(cString: mask)
//                    print("name: \(name), address: \(addressTemp), netmask: \(subnet)")
//                    address = addressTemp
//                    print(toBinary(addressTemp))
                    let networkAddr = toInt(addressTemp) & toInt(subnet)
                    let hostAddr = ~toInt(subnet) & UInt32.max
//                    print(String(format: "%08x", networkAddr))
//                    print(String(format: "%08x", hostAddr))
                    for i in (1..<hostAddr) {
//                        print(toString(networkAddr + i))
                        addesses.append(toString(networkAddr + i))
                    }
                    break
                }
            }
        }
        freeifaddrs(ifaddr)

        return addesses
    }
}

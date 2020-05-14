//
//  NodeRow.swift
//  EchonetScanner
//
//  Created by Katsumi Noguchi on 2020/05/14.
//  Copyright © 2020 WinDesign. All rights reserved.
//

import SwiftUI

struct NodeRow: View {
    var deviceType: Int
    var ipAddress: String

    var body: some View {
        HStack {
            Image(systemName: "star.fill")
            VStack {
                HStack {
                Text(EchonetDefine.nameFromDeviceType(deviceType))
                    .font(.body)
//                    .foregroundColor(.green)
                    Spacer()
                }
                HStack {
                    Text(EchonetDefine.deviceTypeToString(deviceType))
//                        .foregroundColor(.green)
                    Spacer()
                    Text(ipAddress)
                        .foregroundColor(.orange)
                }
            }
            Spacer()
        }
    }
}

struct NodeRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NodeRow(deviceType: 0x0288, ipAddress: "192.168.1.120")
            NodeRow(deviceType: 0x026b, ipAddress: "192.168.1.155")
            NodeRow(deviceType: 0x0130, ipAddress: "192.168.1.158")
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}

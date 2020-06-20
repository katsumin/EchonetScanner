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
            getIcon(deviceType)
                .resizable()
                .padding(.all, 1.0)
                .frame(width: 30.0, height: 30.0)
                .rotationEffect(Angle.init(degrees: EchonetDefine.iconRotateFromDevieType(deviceType)))
            VStack {
                HStack {
                Text(EchonetDefine.nameFromDeviceType(deviceType))
                    .font(.body)
                    Spacer()
                }
                HStack {
                    Text(EchonetDefine.deviceTypeToString(deviceType))
                    Spacer()
                    Text(ipAddress)
                        .foregroundColor(.orange)
                }
            }
            Spacer()
        }
    }
    
    func getIcon(_ deviceType: Int) -> Image {
        let iconName = EchonetDefine.iconFromDevieType(deviceType)
        var image: Image
        if iconName.starts(with: "Other.") {
            image = Image(String(iconName[iconName.index(iconName.startIndex, offsetBy: 6)..<iconName.endIndex]))
        } else {
            image = Image(systemName: iconName)
        }
        return image
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

//
//  PropertyVariations.swift
//  EchonetScanner
//
//  Created by Katsumi Noguchi on 2020/06/03.
//  Copyright © 2020 WinDesign. All rights reserved.
//

import Foundation

class PropertySub: EchonetNode.Property {
}

class PropertySelectable1Byte: PropertySub {
    override func getValue(_ raw: Bool) -> String {
        if values.count < 1 {
            return super.getValue(raw)
        }
        let key = String.init(format: "0x%02x", values[0])
        if !raw, let items = selectItems, let value = items[key] {
            return value
        } else {
            return key
        }
    }
    
    override func convertValue(_ edt: String) -> [UInt8] {
        return hexString2ByteArray(edt, 2, edt.count)
    }
    
    override func getInputType() -> InputType {
        return InputType.SELECTABLE
    }
}

class PropertySelectable3Byte: PropertySub {
    override func getValue(_ raw: Bool) -> String {
        if values.count < 3 {
            return super.getValue(raw)
        }
        let key = String.init(format: "0x%02x%02x%02x", values[0], values[1], values[2])
        if !raw, let items = selectItems, let value = items[key] {
            return value
        } else {
            return key
        }
    }
    
    override func convertValue(_ edt: String) -> [UInt8] {
        return hexString2ByteArray(edt, 2, edt.count)
    }
    
    override func getInputType() -> InputType {
        return InputType.SELECTABLE
    }
}

class PropertySelectableLocation: PropertySub {
    override func getValue(_ raw: Bool) -> String {
        if values.count < 1 {
            return super.getValue(raw)
        }
        let key = String.init(format: "0x%02x", values[0] & 0x78)
        if !raw, let items = selectItems, let value = items[key] {
            return value
        } else {
            return key
        }
    }
    
    override func convertValue(_ edt: String) -> [UInt8] {
        return hexString2ByteArray(edt, 2, edt.count)
    }
    
    override func getInputType() -> InputType {
        return InputType.SELECTABLE
    }
}

class PropertyInstantPower: PropertySub {
    override func getValue(_ raw: Bool) -> String {
        if raw {
            return super.getValue(raw)
        }
        if values.count < 2 {
            return super.getValue(raw)
        }
        let v = UInt16(values[0]) << 8 | UInt16(values[1])
        return String.init(format:"%5dW", v)
    }
}

class PropertyInstantCurrent: PropertySub {
    override func getValue(_ raw: Bool) -> String {
        if raw {
            return super.getValue(raw)
        }
        if values.count < 2 {
            return super.getValue(raw)
        }
        let v = UInt16(values[0]) << 8 | UInt16(values[1])
//        return String.init(format:"%4d.%dA", v / 10, v % 10)
        return String.init(format:"%5.1fA", Double(v) / 10.0)
    }
}

class PropertyInstantPowerSigned: PropertySub {
    override func getValue(_ raw: Bool) -> String {
        if raw {
            return super.getValue(raw)
        }
        if values.count < 4 {
            return super.getValue(raw)
        }
        let v = Int32(values[0]) << 24 | Int32(values[1]) << 16 | Int32(values[2]) << 8 | Int32(values[3])
        if -2147483647 <= v && v <= 2147483645 {
            return String.init(format:"%10dW", v)
        } else {
            return "unknown"
        }
    }
}

class PropertyInstantCurrentSigned: PropertySub {
    override func getValue(_ raw: Bool) -> String {
        if raw {
            return super.getValue(raw)
        }
        if values.count < 4 {
            return super.getValue(raw)
        }
        let r = Int16(values[0]) << 8 | Int16(values[1])
        let t = Int16(values[2]) << 8 | Int16(values[3])
//        return String.init(format:"R:%4d.%dA, T:%4d.%dA", r / 10, r % 10, t / 10, t % 10)
        return String.init(format:"R:%5.1fA, T:%5.1fA", Double(r) / 10.0, Double(t) / 10.0)
    }
}

class PropertyIntegratedPower: PropertySub {
    override func getValue(_ raw: Bool) -> String {
        if raw {
            return super.getValue(raw)
        }
        if values.count < 4 {
            return super.getValue(raw)
        }
        let v = UInt32(values[0]) << 24 | UInt32(values[1]) << 16 | UInt32(values[2]) << 8 | UInt32(values[3])
//        return String.init(format:"%6d.%03dW", v / 1000, v % 1000)
        return String.init(format:"%9.3fkWh", Double(v) / 1000.0)
    }
}

class PropertyInstantCurrentSignedDigit5: PropertySub {
    override func getValue(_ raw: Bool) -> String {
        if raw {
            return super.getValue(raw)
        }
        if values.count < 2 {
            return super.getValue(raw)
        }
        let v = Int16(values[0]) << 8 | Int16(values[1])
        return String.init(format:"%5.1fA", Double(v) / 10.0)
    }
}

class PropertyInstantCurrentUnsignedDigit5: PropertySub {
    override func getValue(_ raw: Bool) -> String {
        if raw {
            return super.getValue(raw)
        }
        if values.count < 2 {
            return super.getValue(raw)
        }
        let v = UInt16(values[0]) << 8 | UInt16(values[1])
        if v <= 65533 {
            return String.init(format:"%5.1fA", Double(v) / 10.0)
        } else {
            return "unknown"
        }
    }
}

class PropertyInstantPowerSignedDigit9: PropertySub {
    override func getValue(_ raw: Bool) -> String {
        if raw {
            return super.getValue(raw)
        }
        if values.count < 4 {
            return super.getValue(raw)
        }
        let v = Int32(values[0]) << 24 | Int32(values[1]) << 16 | Int32(values[2]) << 8 | Int32(values[3])
        if -999999999 <= v && v <= 999999999 {
            return String.init(format:"%9dW", v)
        } else {
            return "unknown"
        }
    }
}

class PropertyInstantPowerUnsignedDigit9: PropertySub {
    override func getValue(_ raw: Bool) -> String {
        if raw {
            return super.getValue(raw)
        }
        if values.count < 4 {
            return super.getValue(raw)
        }
        let v = UInt32(values[0]) << 24 | UInt32(values[1]) << 16 | UInt32(values[2]) << 8 | UInt32(values[3])
        if v <= 999999999 {
            return String.init(format:"%9dW", v)
        } else {
            return "unknown"
        }
    }
}

class PropertyPowerSignedDigit9: PropertySub {
    override func getValue(_ raw: Bool) -> String {
        if raw {
            return super.getValue(raw)
        }
        if values.count < 4 {
            return super.getValue(raw)
        }
        let v = Int32(values[0]) << 24 | Int32(values[1]) << 16 | Int32(values[2]) << 8 | Int32(values[3])
        if -999999999 <= v && v <= 999999999 {
            return String.init(format:"%9dWh", v)
        } else {
            return "unknown"
        }
    }
}

class PropertyCurrentCapacity: PropertySub {
    override func getValue(_ raw: Bool) -> String {
        if raw {
            return super.getValue(raw)
        }
        if values.count < 2 {
            return super.getValue(raw)
        }
        let v = UInt16(values[0]) << 8 | UInt16(values[1])
        return String.init(format:"%5.1fAh", Double(v) / 10.0)
    }
}

class PropertyCurrentSignedCapacity: PropertySub {
    override func getValue(_ raw: Bool) -> String {
        if raw {
            return super.getValue(raw)
        }
        if values.count < 2 {
            return super.getValue(raw)
        }
        let v = Int16(values[0]) << 8 | Int16(values[1])
        return String.init(format:"%5.1fAh", Double(v) / 10.0)
    }
}

class PropertyVoltage: PropertySub {
    override func getValue(_ raw: Bool) -> String {
        if raw {
            return super.getValue(raw)
        }
        if values.count < 2 {
            return super.getValue(raw)
        }
        let v = UInt16(values[0]) << 8 | UInt16(values[1])
        if v <= 32766 {
            return String.init(format:"%5dV", v)
        } else {
            return "unknown"
        }
    }
}

class PropertyVoltageSigned: PropertySub {
    override func getValue(_ raw: Bool) -> String {
        if raw {
            return super.getValue(raw)
        }
        if values.count < 2 {
            return super.getValue(raw)
        }
        let v = Int16(values[0]) << 8 | Int16(values[1])
        if -32767 <= v && v <= 32766 {
            return String.init(format:"%5dV", v)
        } else {
            return "unknown"
        }
    }
}

class PropertyPowerDigit9: PropertySub {
    override func getValue(_ raw: Bool) -> String {
        if raw {
            return super.getValue(raw)
        }
        if values.count < 4 {
            return super.getValue(raw)
        }
        let v = UInt32(values[0]) << 24 | UInt32(values[1]) << 16 | UInt32(values[2]) << 8 | UInt32(values[3])
        return String.init(format:"%9dWh", v)
    }
}

class PropertyPowerMinMax: PropertySub {
    override func getValue(_ raw: Bool) -> String {
        if raw {
            return super.getValue(raw)
        }
        if values.count < 8 {
            return super.getValue(raw)
        }
        let min = UInt32(values[0]) << 24 | UInt32(values[1]) << 16 | UInt32(values[2]) << 8 | UInt32(values[3])
        let max = UInt32(values[4]) << 24 | UInt32(values[5]) << 16 | UInt32(values[6]) << 8 | UInt32(values[7])
        return String.init(format:"Min.:%9dW, Max.:%9dW", min, max)
    }
}

class PropertyCurrentMinMax: PropertySub {
    override func getValue(_ raw: Bool) -> String {
        if raw {
            return super.getValue(raw)
        }
        if values.count < 4 {
            return super.getValue(raw)
        }
        let min = UInt16(values[0]) << 8 | UInt16(values[1])
        let max = UInt16(values[2]) << 8 | UInt16(values[3])
        return String.init(format:"Min.:%5.1fA, Max.:%5.1fA", Double(min) / 10.0, Double(max) / 10.0)
    }
}

class PropertyTemperature: PropertySub {
    override func getValue(_ raw: Bool) -> String {
        if raw {
            return super.getValue(raw)
        }
        if values.count < 1 {
            return super.getValue(raw)
        }
        let v = UInt(values[0])
        if v == 0xfd {
            return "計測不可"
        } else {
            return String.init(format:"%3d℃", v)
        }
    }
}

class PropertyTemperatureSigned: PropertySub {
    override func getValue(_ raw: Bool) -> String {
        if raw {
            return super.getValue(raw)
        }
        if values.count < 1 {
            return super.getValue(raw)
        }
        let v = Int(values[0])
        if -127 <= v && v <= 125 {
            return String.init(format:"%3d℃", v)
        } else if v == -128 {
            return "under flow"
        } else if v == 127 {
            return "over flow"
        } else {
            return "計測不可"
        }
    }
}

class PropertyTemperatureSignedPer10: PropertySub {
    override func getValue(_ raw: Bool) -> String {
        if raw {
            return super.getValue(raw)
        }
        if values.count < 1 {
            return super.getValue(raw)
        }
        let v = Int(values[0])
        if -127 <= v && v <= 125 {
//            return String.init(format:"%2d.%d℃", v / 10, v % 10)
            return String.init(format:"%3.1f℃", Double(v) / 10.0)
        } else if v == -128 {
            return "under flow"
        } else if v == 127 {
            return "over flow"
        } else {
            return "計測不可"
        }
    }
}

class PropertyTemperatureSigned2byte: PropertySub {
    override func getValue(_ raw: Bool) -> String {
        if raw {
            return super.getValue(raw)
        }
        if values.count < 2 {
            return super.getValue(raw)
        }
        let v = Int(values[0]) << 8 | Int(values[1])
        if v > 32766 {
            return "over flow"
        } else if v >= -2732 {
            return String.init(format:"%6.1f℃", Double(v) / 10.0)
        } else {
            return "under flow"
        }
    }
}

class PropertyPressureUnsigned2byte: PropertySub {
    override func getValue(_ raw: Bool) -> String {
        if raw {
            return super.getValue(raw)
        }
        if values.count < 2 {
            return super.getValue(raw)
        }
        let v = UInt(values[0]) << 8 | UInt(values[1])
        if v == 65535 {
            return "over flow"
        } else if v == 65534 {
            return "under flow"
        } else {
            return String.init(format:"%6.1fhPa", Double(v) / 10.0)
        }
    }
}

class PropertyDay1Byte: PropertySub {
    override func getValue(_ raw: Bool) -> String {
        if raw {
            return super.getValue(raw)
        }
        if values.count < 1 {
            return super.getValue(raw)
        }
        let v = UInt(values[0])
        if v <= 0xfc {
            return String.init(format:"%3d日", v)
        } else {
            return "無限"
        }
    }
}

class PropertyHourMinute: PropertySub {
    override func getValue(_ raw: Bool) -> String {
        if raw {
            return super.getValue(raw)
        }
        if values.count < 2 {
            return super.getValue(raw)
        }
        let h = UInt(values[0])
        let m = UInt(values[1])
        return String.init(format:"%02d:%02d", h, m)
    }
    
    override func getInputType() -> InputType {
        return InputType.TIME_HHMM
    }
}

class PropertyYearMonthDay: PropertySub {
    override func getValue(_ raw: Bool) -> String {
        if raw {
            return super.getValue(raw)
        }
        if values.count < 4 {
            return super.getValue(raw)
        }
        let y = UInt(values[0]) << 8 | UInt(values[1])
        let m = UInt(values[2])
        let d = UInt(values[3])
        return String.init(format:"%04d/%02d/%02d", y, m, d)
    }
    
    override func getInputType() -> InputType {
        return InputType.DATE_YYYYMMDD
    }
}

class PropertyPercent: PropertySub {
    override func getValue(_ raw: Bool) -> String {
        if raw {
            return super.getValue(raw)
        }
        if values.count < 1 {
            return super.getValue(raw)
        }
        let v = UInt(values[0])
        if v == 0xfd {
            return "計測不可"
        } else if v == 0xfe {
            return "under flow"
        } else if v == 0xff {
            return "over flow"
        }
        return String.init(format:"%3d%%", v)
    }
}

class PropertyCapacity2Byte: PropertySub {
    override func getValue(_ raw: Bool) -> String {
        if raw {
            return super.getValue(raw)
        }
        if values.count < 2 {
            return super.getValue(raw)
        }
        let v = UInt(values[0]) << 8 | UInt(values[1])
        return String.init(format:"%5dL", v)
    }
}

class PropertyCapacity1Byte: PropertySub {
    override func getValue(_ raw: Bool) -> String {
        if raw {
            return super.getValue(raw)
        }
        if values.count < 1 {
            return super.getValue(raw)
        }
        let v = UInt(values[0])
        return String.init(format:"%3dL", v)
    }
}

class PropertyTotalOperatingTime: PropertySub {
    override func getValue(_ raw: Bool) -> String {
        if raw {
            return super.getValue(raw)
        }
        if values.count < 5 {
            return super.getValue(raw)
        }
        let v = UInt(values[1]) << 24 | UInt(values[2]) << 16 | UInt(values[3]) << 8 | UInt(values[4])
        switch values[0] {
        case 0x41:
            return String.init(format:"%10d秒", v)
        case 0x42:
            return String.init(format:"%10d分", v)
        case 0x43:
            return String.init(format:"%10d時", v)
        case 0x44:
            return String.init(format:"%10d日", v)
        default:
            return super.getValue(raw)
        }
    }
}

class PropertyInteger4Byte: PropertySub {
    override func getValue(_ raw: Bool) -> String {
        if raw {
            return super.getValue(raw)
        }
        if values.count < 4 {
            return super.getValue(raw)
        }
        let v = UInt(values[0]) << 24 | UInt(values[1]) << 16 | UInt(values[2]) << 8 | UInt(values[3])
        return String.init(format:"%6d", v)
    }
}

class PropertyEnergy4Byte: PropertySub {
    var d3:UInt32 = 1
//    var d7:UInt = 6
    var e1 = 0x01
    
    override func getValue(_ raw: Bool) -> String {
        if raw {
            return super.getValue(raw)
        }
        if values.count < 4 {
            return super.getValue(raw)
        }
        var v = UInt32(values[0]) << 24 | UInt32(values[1]) << 16 | UInt32(values[2]) << 8 | UInt32(values[3])
        v *= d3
        switch e1 {
        case 0x00:
            return String.init(format:"%8dkWh", v)
        case 0x01:
            return String.init(format:"%7d.%dkWh", v / 10, v % 10)
        case 0x02:
            return String.init(format:"%6d.%02dkWh", v / 100, v % 100)
        case 0x03:
            return String.init(format:"%5d.%03dkWh", v / 1000, v % 1000)
        case 0x04:
            return String.init(format:"%4d.%04dkWh", v / 10000, v % 10000)
        case 0x0a:
            return String.init(format:"%8d0kWh", v)
        case 0x0b:
            return String.init(format:"%8d00kWh", v)
        case 0x0c:
            return String.init(format:"%8d000kWh", v)
        case 0x0d:
            return String.init(format:"%8d0000kWh", v)
        default:
            return String.init(format:"%7d.%dkWh", v / 10, v % 10)
        }
    }
}

class PropertyEnergyInterval: PropertySub {
    var d3:UInt = 1
//    var d7:UInt = 6
    var e1 = 0x01
    
    override func getValue(_ raw: Bool) -> String {
        if raw {
            return super.getValue(raw)
        }
        if values.count < 11 {
            return super.getValue(raw)
        }
        let y = UInt(values[0]) << 8 | UInt(values[1])
        let m = UInt(values[2])
        let d = UInt(values[3])
        let h = UInt(values[4])
        let min = UInt(values[5])
        let s = UInt(values[6])
        var v = UInt(values[7]) << 24 | UInt(values[8]) << 16 | UInt(values[9]) << 8 | UInt(values[10])
        v *= d3
        let dateStr = String.init(format:"%04d/%02d/%02d %02d:%02d:%02d", y, m, d, h, min, s)
        switch e1 {
        case 0x00:
            return dateStr + String.init(format:", %8dkWh", v)
        case 0x01:
            return dateStr + String.init(format:", %7d.%dkWh", v / 10, v % 10)
        case 0x02:
            return dateStr + String.init(format:", %6d.%02dkWh", v / 100, v % 100)
        case 0x03:
            return dateStr + String.init(format:", %5d.%03dkWh", v / 1000, v % 1000)
        case 0x04:
            return dateStr + String.init(format:", %4d.%04dkWh", v / 10000, v % 10000)
        case 0x0a:
            return dateStr + String.init(format:", %8d0kWh", v)
        case 0x0b:
            return dateStr + String.init(format:", %8d00kWh", v)
        case 0x0c:
            return dateStr + String.init(format:", %8d000kWh", v)
        case 0x0d:
            return dateStr + String.init(format:", %8d0000kWh", v)
        default:
            return dateStr + String.init(format:", %7d.%dkWh", v / 10, v % 10)
        }
    }
}

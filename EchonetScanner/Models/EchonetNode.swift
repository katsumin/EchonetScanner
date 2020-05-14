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

struct EchonetNode: Hashable, Codable {
//struct EchonetNode: Hashable, Codable, Identifiable {
//    var id: Int
    var name: String
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


    // プロパティ定義
    struct Property: Hashable, Codable {
        var epc: Int
//        var name: String
        var gettable: Bool
        var settable: Bool
//        var parent: EchonetNode
    }
}

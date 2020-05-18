//
//  UserData.swift
//  EchonetScanner
//
//  Created by Katsumi Noguchi on 2020/05/12.
//  Copyright © 2020 WinDesign. All rights reserved.
//

import SwiftUI

import Combine

final class UserData : ObservableObject {
//    @Published var showFavoritesOnly = false
//    @Published var landMarks = landmarkData
    @Published var echonetNodes = echonetNodeDatas
}

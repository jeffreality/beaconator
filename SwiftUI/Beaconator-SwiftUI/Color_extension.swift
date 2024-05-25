//
//  Color_extension.swift
//  Beaconator-SwiftUI
//
//  Created by Jeffrey Berthiaume on 5/24/24.
//

import Foundation
import SwiftUI

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var hexNumber: UInt64 = 0
        let mask = 0x000000FF

        scanner.scanHexInt64(&hexNumber)

        let r = CGFloat((hexNumber >> 16) & UInt64(mask)) / 255.0
        let g = CGFloat((hexNumber >> 8) & UInt64(mask)) / 255.0
        let b = CGFloat(hexNumber & UInt64(mask)) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}

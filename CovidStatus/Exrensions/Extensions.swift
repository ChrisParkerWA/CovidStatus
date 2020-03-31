//
//  Extensions.swift
//  CovidSatus
//
//  Created by Chris Parker on 16/3/20.
//  Copyright © 2020 Chris Parker. All rights reserved.
//

import SwiftUI

extension Color {
    static func rgb(r: Double, g: Double, b: Double) -> Color {
        return Color(red: r / 255, green: g / 255, blue: b / 255)
    }
    
    static let backgroundColor = Color.rgb(r: 21, g: 22, b: 33)
    static let outlineColor = Color.rgb(r: 54, g: 255, b: 203)
    static let trackColor = Color.rgb(r: 45, g: 56, b: 95)
    static let pulsatingColor = Color.rgb(r: 73, g: 113, b: 148)
    static let cyanColor = Color.rgb(r: 0, g: 255, b: 255)
    static let listRowColorTop = Color.rgb(r: 0, g: 200, b: 200)
    static let listRowColorBottom = Color.rgb(r: 0, g: 150, b: 150)
}

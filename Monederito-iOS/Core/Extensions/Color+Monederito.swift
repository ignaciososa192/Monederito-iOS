//
//  Color+Monederito.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 06/03/2026.
//

import SwiftUI

// Paleta de colores extraída del PDF (naranja principal, acento púrpura)
extension Color {
    // Colores de marca — consistentes con frontend Monederito
    static let monederitoOrange     = Color(hex: "#F0853A") // naranja principal
    static let monederitoPurple     = Color(hex: "#7C3AED") // púrpura acento
    static let monederitoBackground = Color(hex: "#FAF0E6") // fondo cálido
    
    // Colores semánticos
    static let riskRed      = Color(hex: "#E53A3A")
    static let safeGreen    = Color(hex: "#38B371")
    static let warningAmber = Color(hex: "#F2B310")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

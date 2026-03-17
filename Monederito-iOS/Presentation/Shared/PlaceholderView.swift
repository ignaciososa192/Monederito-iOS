//
//  PlaceholderView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 16/03/2026.
//

import SwiftUI

struct PlaceholderView: View {
    let title: String
    let icon: String
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundStyle(Color.monederitoOrange)

            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

            Text("Próximamente...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.monederitoBackground.ignoresSafeArea())
    }
}

#Preview {
    PlaceholderView(title: "Placeholder", icon: "person.2.fill")
}

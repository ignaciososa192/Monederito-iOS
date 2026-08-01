//
//  GoogleSignInButton.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 19/04/2026.
//

import SwiftUI
import GoogleSignInSwift

struct MonederitoGoogleSignInButton: View {
    
    let action: () -> Void
    let isLoading: Bool
    
    var body: some View {
        GoogleSignInButton(
            scheme: .light,
            style: .wide,
            state: isLoading ? .disabled : .normal,
            action: action
        )
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }
}

#Preview {
    VStack(spacing: 16) {
        MonederitoGoogleSignInButton(action: {}, isLoading: false)
        MonederitoGoogleSignInButton(action: {}, isLoading: true)
    }
    .padding()
}

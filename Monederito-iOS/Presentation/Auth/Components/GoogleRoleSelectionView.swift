//
//  GoogleRoleSelectionView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 20/04/2026.
//

import SwiftUI

struct GoogleRoleSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedRole: UserRole?
    let onConfirm: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("¿Cómo querés usar Monederito?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                RolePickerView(selectedRole: Binding(
                    get: { selectedRole ?? .benefactor },
                    set: { selectedRole = $0 }
                ))

                Button {
                    onConfirm()
                    dismiss()
                } label: {
                    Text("Continuar con Google")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.monederitoOrange)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(selectedRole == nil)
            }
            .padding(24)
            .navigationTitle("Google Sign-In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    GoogleRoleSelectionView(
        selectedRole: .constant(.benefactor),
        onConfirm: {}
    )
}

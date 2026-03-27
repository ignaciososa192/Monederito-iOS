//
//  AuthTextField.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 27/03/2026.
//

import SwiftUI

// Componente reutilizable para campos de formulario de auth
// CONCEPTO: @Binding — recibe el valor del padre y lo modifica

struct AuthTextField: View {
    
    let title: String
    let icon: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    var showToggle: Bool = false
    @Binding var isVisible: Bool
    var isValid: Bool? = nil  // nil = sin validar, true = válido, false = inválido
    
    // CONCEPTO: @FocusState — controla el foco del teclado
    // Permite saber qué campo está activo y mover el foco programáticamente
    @FocusState private var isFocused: Bool
    
    init(
        title: String,
        icon: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default,
        isSecure: Bool = false,
        showToggle: Bool = false,
        isVisible: Binding<Bool> = .constant(true),
        isValid: Bool? = nil
    ) {
        self.title = title
        self.icon = icon
        self._text = text
        self.keyboardType = keyboardType
        self.isSecure = isSecure
        self.showToggle = showToggle
        self._isVisible = isVisible
        self.isValid = isValid
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            
            // Label
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(labelColor)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .frame(width: 20)
                
                // CONCEPTO: Group para alternar entre SecureField y TextField
                Group {
                    if isSecure && !isVisible {
                        SecureField("", text: $text)
                    } else {
                        TextField("", text: $text)
                            .keyboardType(keyboardType)
                            .autocapitalization(keyboardType == .emailAddress ? .none : .words)
                            .autocorrectionDisabled(keyboardType == .emailAddress)
                    }
                }
                .focused($isFocused)
                
                // Toggle de visibilidad para passwords
                if showToggle {
                    Button {
                        isVisible.toggle()
                    } label: {
                        Image(systemName: isVisible ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                }
                
                // Ícono de validación
                if let isValid, !text.isEmpty {
                    Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(isValid ? Color.safeGreen : Color.riskRed)
                        .font(.caption)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isFocused ? Color.monederitoOrange.opacity(0.05) : Color.gray.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 1.5)
            )
        }
    }
    
    private var borderColor: Color {
        if let isValid, !text.isEmpty {
            return isValid ? Color.safeGreen.opacity(0.5) : Color.riskRed.opacity(0.5)
        }
        return isFocused ? Color.monederitoOrange : Color.clear
    }
    
    private var iconColor: Color {
        isFocused ? Color.monederitoOrange : Color.gray
    }
    
    private var labelColor: Color {
        if let isValid, !text.isEmpty {
            return isValid ? Color.safeGreen : Color.riskRed
        }
        return isFocused ? Color.monederitoOrange : Color.gray
    }
}

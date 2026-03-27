//
//  RegisterView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 27/03/2026.
//

import SwiftUI

struct RegisterView: View {
    
    @Environment(AppState.self) private var appState
    @Environment(DependencyContainer.self) private var container
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel = AuthViewModel()
    @State private var currentStep: Int = 1
    
    // CONCEPTO: @FocusState con enum para múltiples campos
    @FocusState private var focusedField: Field?
    
    enum Field { case fullName, phone, email, password, confirmPassword }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.monederitoBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // Progress bar
                    progressBar
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            
                            // Step header
                            stepHeader
                            
                            // Contenido según el paso
                            if currentStep == 1 {
                                stepOneContent
                            } else {
                                stepTwoContent
                            }
                            
                            // Error
                            if let error = viewModel.errorMessage {
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(Color.riskRed)
                                    Text(error)
                                        .font(.caption)
                                        .foregroundColor(Color.riskRed)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            // Botón continuar / registrar
                            actionButton
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 24)
                    }
                }
            }
            .navigationTitle("Crear cuenta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        if currentStep > 1 {
                            withAnimation { currentStep -= 1 }
                        } else {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: currentStep > 1 ? "chevron.left" : "xmark")
                            .foregroundColor(Color.monederitoOrange)
                    }
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 3)
                
                Rectangle()
                    .fill(Color.monederitoOrange)
                    .frame(width: geo.size.width * (Double(currentStep) / 2.0), height: 3)
                    .animation(.spring(duration: 0.4), value: currentStep)
            }
        }
        .frame(height: 3)
    }
    
    @ViewBuilder
    private var stepHeader: some View {
        VStack(spacing: 8) {
            Text("Paso \(currentStep) de 2")
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(currentStep == 1 ? "¿Quién sos?" : "Tus credenciales")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text(currentStep == 1
                 ? "Contanos un poco sobre vos para personalizar tu experiencia"
                 : "Elegí un email y contraseña seguros")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
    }
    
    @ViewBuilder
    private var stepOneContent: some View {
        VStack(spacing: 16) {
            
            // Selector de rol
            RolePickerView(selectedRole: $viewModel.selectedRole)
            
            AuthTextField(
                title: "Nombre completo",
                icon: "person.fill",
                text: $viewModel.fullName,
                isValid: viewModel.fullName.isEmpty ? nil
                    : !viewModel.fullName.trimmingCharacters(in: .whitespaces).isEmpty
            )
            .focused($focusedField, equals: .fullName)
            .submitLabel(.next)
            .onSubmit { focusedField = .phone }
            
            AuthTextField(
                title: "Teléfono",
                icon: "phone.fill",
                text: $viewModel.phone,
                keyboardType: .phonePad,
                isValid: viewModel.phone.isEmpty ? nil : viewModel.isPhoneValid
            )
            .focused($focusedField, equals: .phone)
        }
    }
    
    @ViewBuilder
    private var stepTwoContent: some View {
        VStack(spacing: 16) {
            
            AuthTextField(
                title: "Email",
                icon: "envelope.fill",
                text: $viewModel.email,
                keyboardType: .emailAddress,
                isValid: viewModel.email.isEmpty ? nil : viewModel.isEmailValid
            )
            .focused($focusedField, equals: .email)
            .submitLabel(.next)
            .onSubmit { focusedField = .password }
            
            AuthTextField(
                title: "Contraseña (mínimo 8 caracteres)",
                icon: "lock.fill",
                text: $viewModel.password,
                isSecure: true,
                showToggle: true,
                isVisible: $viewModel.showPassword,
                isValid: viewModel.password.isEmpty ? nil : viewModel.isPasswordValid
            )
            .focused($focusedField, equals: .password)
            .submitLabel(.next)
            .onSubmit { focusedField = .confirmPassword }
            
            AuthTextField(
                title: "Confirmar contraseña",
                icon: "lock.shield.fill",
                text: $viewModel.confirmPassword,
                isSecure: true,
                showToggle: true,
                isVisible: $viewModel.showConfirmPassword,
                isValid: viewModel.confirmPassword.isEmpty ? nil : viewModel.doPasswordsMatch
            )
            .focused($focusedField, equals: .confirmPassword)
            .submitLabel(.done)
            .onSubmit { focusedField = nil }
            
            // Tip de seguridad
            HStack(spacing: 8) {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundColor(Color.safeGreen)
                    .font(.caption)
                Text("Tu contraseña está protegida con encriptación de nivel bancario")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .padding(10)
            .background(Color.safeGreen.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    @ViewBuilder
    private var actionButton: some View {
        VStack(spacing: 12) {
            Button {
                focusedField = nil
                if currentStep == 1 {
                    withAnimation { currentStep = 2 }
                } else {
                    Task {
                        await viewModel.signUp(
                            using: container.authRepository,
                            appState: appState
                        )
                    }
                }
            } label: {
                HStack {
                    if viewModel.isLoading {
                        ProgressView().tint(.white).scaleEffect(0.8)
                    } else {
                        Text(currentStep == 1 ? "Continuar" : "Crear cuenta")
                            .fontWeight(.semibold)
                        Image(systemName: currentStep == 1 ? "arrow.right" : "checkmark")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isStepValid ? Color.monederitoOrange : Color.gray.opacity(0.3))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(!isStepValid || viewModel.isLoading)
            .animation(.easeInOut(duration: 0.2), value: isStepValid)
            
            if currentStep == 2 {
                Text("Al crear tu cuenta aceptás nuestros Términos y Condiciones y Política de Privacidad")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var isStepValid: Bool {
        if currentStep == 1 {
            return !viewModel.fullName.trimmingCharacters(in: .whitespaces).isEmpty
                && viewModel.isPhoneValid
        } else {
            return viewModel.isRegisterFormValid
        }
    }
}

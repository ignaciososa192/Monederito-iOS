//
//  LoginView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 17/03/2026.
//

import SwiftUI

struct LoginView: View {
    
    @Environment(AppState.self) private var appState
    @Environment(DependencyContainer.self) private var container
    
    @State private var viewModel = AuthViewModel()
    @State private var showRegister: Bool = false
    @State private var showOnboarding: Bool = false
    
    // CONCEPTO: @FocusState con enum
    // Permite controlar qué campo tiene el foco del teclado
    // y saltar entre campos con el botón "Next" del teclado.
    @FocusState private var focusedField: Field?
    
    enum Field { case email, password }
    
    var body: some View {
        ZStack {
            Color.monederitoBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    
                    // Header
                    headerSection
                    
                    // Formulario
                    formSection
                    
                    // Acciones
                    actionsSection
                    
                    // Separador
                    dividerSection
                    
                    // Registro
                    registerSection
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 40)
            }
        }
        .onAppear {
            viewModel.checkBiometricAvailability()
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView(showOnboarding: $showOnboarding)
        }
        .sheet(isPresented: $showRegister) {
            RegisterView()
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.monederitoOrange.opacity(0.12))
                    .frame(width: 90, height: 90)
                Image(systemName: "wallet.pass.fill")
                    .font(.system(size: 44))
                    .foregroundColor(Color.monederitoOrange)
            }
            
            Text("Monederito")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text("Mucho más que una billetera virtual")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button {
                showOnboarding = true
            } label: {
                Text("¿Qué es Monederito?")
                    .font(.caption)
                    .foregroundColor(Color.monederitoOrange)
                    .underline()
            }
        }
        .padding(.top, 20)
    }
    
    @ViewBuilder
    private var formSection: some View {
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
                title: "Contraseña",
                icon: "lock.fill",
                text: $viewModel.password,
                isSecure: true,
                showToggle: true,
                isVisible: $viewModel.showPassword,
                isValid: viewModel.password.isEmpty ? nil : viewModel.isPasswordValid
            )
            .focused($focusedField, equals: .password)
            .submitLabel(.done)
            .onSubmit { focusedField = nil }
            
            // Error message
            if let error = viewModel.errorMessage {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(Color.riskRed)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(Color.riskRed)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            // Olvidé mi contraseña
            HStack {
                Spacer()
                Button("¿Olvidaste tu contraseña?") {
                    // Paso 13: implementar reset
                }
                .font(.caption)
                .foregroundColor(Color.monederitoOrange)
            }
        }
    }
    
    @ViewBuilder
    private var actionsSection: some View {
        VStack(spacing: 12) {
            
            // Botón principal Login
            Button {
                focusedField = nil
                Task {
                    await viewModel.signIn(
                        using: container.authRepository,
                        appState: appState
                    )
                }
            } label: {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(0.8)
                    } else {
                        Text("Ingresar")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    viewModel.isLoginFormValid
                    ? Color.monederitoOrange
                    : Color.gray.opacity(0.3)
                )
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(!viewModel.isLoginFormValid || viewModel.isLoading)
            .animation(.easeInOut(duration: 0.2), value: viewModel.isLoginFormValid)
            
            // Biometría
            if viewModel.biometricType != .none {
                Button {
                    Task {
                        await viewModel.authenticateWithBiometrics(
                            using: container.authRepository,
                            appState: appState
                        )
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: viewModel.biometricType.icon)
                            .font(.title3)
                        Text("Ingresar con \(viewModel.biometricType.label)")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.monederitoOrange.opacity(0.08))
                    .foregroundColor(Color.monederitoOrange)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            
            // Dev buttons — SOLO para desarrollo
            #if DEBUG
            VStack(spacing: 8) {
                Text("Acceso rápido (DEBUG)")
                    .font(.caption2)
                    .foregroundColor(.gray)
                HStack(spacing: 8) {
                    Button("Elena (Benefactor)") {
                        appState.loginAsBenefactor()
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.monederitoOrange.opacity(0.1))
                    .foregroundColor(Color.monederitoOrange)
                    .clipShape(Capsule())
                    
                    Button("Lucas (Beneficiario)") {
                        appState.loginAsBeneficiary()
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.monederitoPurple.opacity(0.1))
                    .foregroundColor(Color.monederitoPurple)
                    .clipShape(Capsule())
                }
            }
            .padding(.top, 8)
            #endif
        }
    }
    
    @ViewBuilder
    private var dividerSection: some View {
        HStack {
            Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 1)
            Text("o").font(.caption).foregroundColor(.gray).padding(.horizontal, 8)
            Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 1)
        }
    }
    
    @ViewBuilder
    private var registerSection: some View {
        VStack(spacing: 16) {
            Text("¿No tenés cuenta?")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Button {
                showRegister = true
            } label: {
                Text("Crear cuenta gratis")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.white)
                    .foregroundColor(Color.monederitoOrange)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.monederitoOrange, lineWidth: 1.5)
                    )
            }
        }
    }
}

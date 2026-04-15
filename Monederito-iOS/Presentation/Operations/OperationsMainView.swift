//
//  OperationsMainView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 07/04/2026.
//

import SwiftUI

struct OperationsMainView: View {
    
    @Environment(AppState.self) private var appState
    @State private var selectedOperation: OperationType? = nil
    @State private var recentContacts: [TransferDestination] = []
    
    enum OperationType: Hashable {
        case transfer, phoneRecharge, subeRecharge, services, qr
        
        var title: String {
            switch self {
            case .transfer:      return "Transferir"
            case .phoneRecharge: return "Recargar cel."
            case .subeRecharge:  return "SUBE"
            case .services:      return "Servicios"
            case .qr:            return "Pagar QR"
            }
        }
        
        var icon: String {
            switch self {
            case .transfer:      return "arrow.right.arrow.left"
            case .phoneRecharge: return "phone.fill"
            case .subeRecharge:  return "tram.fill"
            case .services:      return "bolt.fill"
            case .qr:            return "qrcode.viewfinder"
            }
        }
        
        var color: Color {
            switch self {
            case .transfer:      return Color.monederitoPurple
            case .phoneRecharge: return Color.safeGreen
            case .subeRecharge:  return Color.warningAmber
            case .services:      return Color(hex: "#E91E8C")
            case .qr:            return Color.monederitoOrange
            }
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                headerSection
                quickActionsGrid
                recentContactsSection
            }
            .padding(.vertical)
        }
        .background(Color.monederitoBackground.ignoresSafeArea())
        .navigationTitle("Operaciones")
        .navigationBarTitleDisplayMode(.large)
        .task {
            loadRecentContacts()
            // Si viene un deep link desde el dashboard, navegar directo
            if let pending = appState.pendingOperation {
                selectedOperation = pending
                appState.pendingOperation = nil
            }
        }
        // CONCEPTO: navigationDestination con tipo Hashable
        // Navegación programática tipada — sin strings
        .navigationDestination(item: $selectedOperation) { operation in
            destinationView(for: operation)
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Realizá tus operaciones")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
            Text("Transferencias, recargas y pagos")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var quickActionsGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Operaciones rápidas")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                spacing: 12
            ) {
                ForEach([OperationType.qr, .transfer, .phoneRecharge, .subeRecharge, .services], id: \.self) { operation in
                    operationCard(operation)
                }
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private func operationCard(_ operation: OperationType) -> some View {
        Button {
            selectedOperation = operation
        } label: {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(operation.color.opacity(0.12))
                        .frame(width: 64, height: 64)
                    Image(systemName: operation.icon)
                        .font(.title2)
                        .foregroundColor(operation.color)
                }
                Text(operation.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
        }
    }
    
    @ViewBuilder
    private var recentContactsSection: some View {
        if !recentContacts.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Contactos recientes")
                    .font(.headline)
                    .padding(.horizontal)
                
                VStack(spacing: 0) {
                    ForEach(recentContacts) { contact in
                        Button {
                            selectedOperation = .transfer
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color.monederitoPurple.opacity(0.12))
                                        .frame(width: 40, height: 40)
                                    Text(contact.recipientName.prefix(1).uppercased())
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.monederitoPurple)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(contact.recipientName)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.black)
                                    Text(contact.alias ?? contact.displayIdentifier)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                if contact.isMonederitoUser {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.caption)
                                        .foregroundColor(Color.safeGreen)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(.plain)
                        
                        if contact.id != recentContacts.last?.id {
                            Divider().padding(.horizontal, 16)
                        }
                    }
                }
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Private Methods
    private func loadRecentContacts() {
        recentContacts = [
            TransferDestination(
                recipientName: "Mamá",
                cbuOrCvu: "0000003100050000000001",
                alias: "mama.monederito",
                isMonederitoUser: true
            ),
            TransferDestination(
                recipientName: "Juan Pérez",
                cbuOrCvu: "0720461088000071507029",
                alias: "juan.perez.mp",
                isMonederitoUser: false
            ),
            TransferDestination(
                recipientName: "Sofia García",
                cbuOrCvu: "0000003100050000000002",
                alias: "sofi.garcia",
                isMonederitoUser: true
            )
        ]
    }
    
    @ViewBuilder
    private func destinationView(for operation: OperationType) -> some View {
        switch operation {
        case .qr:            QRPaymentView()
        case .transfer:      TransferView()
        case .phoneRecharge: PhoneRechargeView()
        case .subeRecharge:  SUBERechargeView()
        case .services:      ServicePaymentView()
        }
    }
}

//
//  AlertsView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 30/03/2026.
//

import SwiftUI

struct AlertsView: View {
    
    @Environment(AppState.self) private var appState
    @Environment(DependencyContainer.self) private var container
    
    @State private var viewModel = AlertsViewModel()
    @State private var selectedAlert: RiskAlert? = nil
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                
                if viewModel.pendingCount > 0 {
                    pendingSummaryBanner
                }
                
                filterPicker
                
                if viewModel.filteredAlerts.isEmpty {
                    emptyState
                } else {
                    alertsList
                }
            }
            .padding(.vertical)
        }
        .background(Color.monederitoBackground.ignoresSafeArea())
        .navigationTitle("Alertas")
        .navigationBarTitleDisplayMode(.large)
        .searchable(
            text: $viewModel.searchText,
            prompt: "Buscar por comercio o categoría"
        )
        .task {
            if let userID = appState.currentUser?.id {
                await viewModel.loadAlerts(
                    for: userID,
                    using: container.transactionRepository
                )
            }
        }
        .sheet(item: $selectedAlert) { alert in
            AlertDetailView(
                alert: alert,
                onApprove: {
                    Task {
                        await viewModel.resolveAlert(
                            alert,
                            status: AlertStatus.approved,
                            using: container.transactionRepository
                        )
                    }
                },
                onDeny: {
                    Task {
                        await viewModel.resolveAlert(
                            alert,
                            status: AlertStatus.denied,
                            using: container.transactionRepository
                        )
                    }
                }
            )
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var pendingSummaryBanner: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.riskRed.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(Color.riskRed)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(viewModel.pendingCount) alerta\(viewModel.pendingCount > 1 ? "s" : "") pendiente\(viewModel.pendingCount > 1 ? "s" : "")")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Color.riskRed)
                Text("Requieren tu atención inmediata")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.riskRed.opacity(0.1), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.riskRed.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
        .onTapGesture {
            viewModel.selectedFilter = AlertsViewModel.AlertFilter.pending
        }
    }
    
    @ViewBuilder
    private var filterPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(AlertsViewModel.AlertFilter.allCases, id: \.self) { filter in
                    filterChip(filter)
                }
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private func filterChip(_ filter: AlertsViewModel.AlertFilter) -> some View {
        let isSelected = viewModel.selectedFilter == filter
        let count = viewModel.countFor(filter)
        
        Button {
            withAnimation(.spring(duration: 0.3)) {
                viewModel.selectedFilter = filter
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: filter.icon)
                    .font(.caption)
                Text(filter.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                if count > 0 {
                    Text("\(count)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(isSelected ? .white.opacity(0.3) : filter.color.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
            .foregroundColor(isSelected ? .white : filter.color)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                isSelected
                ? filter.color
                : filter.color.opacity(0.1)
            )
            .clipShape(Capsule())
        }
    }
    
    @ViewBuilder
    private var alertsList: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.filteredAlerts) { alert in
                Button {
                    selectedAlert = alert
                } label: {
                    AlertHistoryRowView(alert: alert)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                }
                
                if alert.id != viewModel.filteredAlerts.last?.id {
                    Divider().padding(.horizontal, 16)
                }
            }
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: viewModel.selectedFilter == AlertsViewModel.AlertFilter.pending
                  ? "checkmark.shield.fill"
                  : "bell.slash.fill")
                .font(.system(size: 50))
                .foregroundColor(viewModel.selectedFilter.color.opacity(0.5))
            
            Text(viewModel.selectedFilter == AlertsViewModel.AlertFilter.pending
                 ? "¡Todo bajo control!"
                 : "Sin alertas \(viewModel.selectedFilter.rawValue.lowercased())")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.black)
            
            Text(viewModel.selectedFilter == AlertsViewModel.AlertFilter.pending
                 ? "No hay gastos de riesgo pendientes de revisión"
                 : "No encontramos alertas con este filtro")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

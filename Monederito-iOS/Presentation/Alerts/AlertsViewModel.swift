//
//  AlertsViewModel.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 30/03/2026.
//

import SwiftUI

@Observable
class AlertsViewModel {
    
    // MARK: - State
    var allAlerts: [RiskAlert] = []
    var isLoading: Bool = false
    var searchText: String = ""
    var selectedFilter: AlertFilter = .all
    
    // MARK: - Filter enum
    enum AlertFilter: String, CaseIterable {
        case all      = "Todas"
        case pending  = "Pendientes"
        case approved = "Aprobadas"
        case denied   = "Denegadas"
        
        var status: AlertStatus? {
            switch self {
            case .all:      return nil
            case .pending:  return .pending
            case .approved: return .approved
            case .denied:   return .denied
            }
        }
        
        var color: Color {
            switch self {
            case .all:      return Color.monederitoOrange
            case .pending:  return Color.warningAmber
            case .approved: return Color.safeGreen
            case .denied:   return Color.riskRed
            }
        }
        
        var icon: String {
            switch self {
            case .all:      return "bell.fill"
            case .pending:  return "clock.fill"
            case .approved: return "checkmark.circle.fill"
            case .denied:   return "xmark.circle.fill"
            }
        }
    }
    
    // MARK: - Init
    init() { }
    
    // MARK: - Computed
    var filteredAlerts: [RiskAlert] {
        var result = allAlerts
        
        if let status = selectedFilter.status {
            result = result.filter { $0.status == status }
        }
        
        if !searchText.isEmpty {
            result = result.filter {
                $0.merchant.localizedCaseInsensitiveContains(searchText) ||
                $0.category.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result.sorted {
            if $0.status.isPending != $1.status.isPending {
                return $0.status.isPending
            }
            return $0.createdAt > $1.createdAt
        }
    }
    
    var pendingCount: Int {
        allAlerts.filter { $0.status.isPending }.count
    }
    
    func countFor(_ filter: AlertFilter) -> Int {
        if let status = filter.status {
            return allAlerts.filter { $0.status == status }.count
        }
        return allAlerts.count
    }
    
    // MARK: - Load
    func loadAlerts(for benefactorID: UUID, using repo: any TransactionRepositoryProtocol) async {
        isLoading = true
        do {
            let pending = try await repo.getPendingAlerts(for: benefactorID)
            allAlerts = pending + MockData.alertHistory
        } catch {
            allAlerts = MockData.alertHistory
        }
        isLoading = false
    }
    
    // MARK: - Actions
    func resolveAlert(_ alert: RiskAlert, status: AlertStatus, using repo: any TransactionRepositoryProtocol) async {
        if let index = allAlerts.firstIndex(where: { $0.id == alert.id }) {
            allAlerts[index].status = status
            allAlerts[index].resolvedAt = Date()
        }
        do {
            _ = try await repo.resolveAlert(alertID: alert.id, status: status)
        } catch {
            if let index = allAlerts.firstIndex(where: { $0.id == alert.id }) {
                allAlerts[index].status = .pending
                allAlerts[index].resolvedAt = nil
            }
        }
    }
}

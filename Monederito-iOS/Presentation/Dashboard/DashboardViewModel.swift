//
//  DashboardViewModel.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 17/03/2026.
//

import SwiftUI

// CONCEPTO: ViewModel en MVVM
// El ViewModel es el intermediario entre los datos (Domain)
// y la Vista (SwiftUI). La View NUNCA habla directamente
// con los repositorios — siempre pasa por el ViewModel.
//
// Flujo: View → ViewModel → Repository → Domain Model
//                ↑______________________________↓

@Observable
class DashboardViewModel {
    
    // MARK: - State
    var pendingAlerts: [RiskAlert] = []
    var recentTransactions: [Transaction] = []
    var beneficiaryAccounts: [BeneficiaryAccount] = []
    var spendingByCategory: [TransactionCategory: Double] = [:]
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    // MARK: - Computed Properties
    
    // Total gastado este mes por todos los beneficiarios
    var totalMonthlySpending: Double {
        spendingByCategory.values.reduce(0, +)
    }
    
    // Alertas urgentes (llevan más de 3 minutos sin resolver)
    var urgentAlerts: [RiskAlert] {
        pendingAlerts.filter { $0.isUrgent }
    }
    
    // Datos para el gráfico — ordenados por monto
    var chartData: [(category: TransactionCategory, amount: Double)] {
        spendingByCategory
            .sorted { $0.value > $1.value }
            .map { (category: $0.key, amount: $0.value) }
    }
    
    // MARK: - Load Data
    
    // CONCEPTO: async/await
    // 'async' significa que esta función puede pausarse mientras espera
    // (por ejemplo, una llamada a red) sin bloquear el hilo principal.
    // 'await' es el punto donde se pausa.
    // En el Paso 7 esto llamará a Supabase — por ahora usa MockData.
    
    func loadDashboard(for userID: UUID) async {
        isLoading = true
        errorMessage = nil
        
        // CONCEPTO: do/catch — manejo de errores en Swift
        // Como las funciones del repositorio son 'throws',
        // debemos envolver la llamada en do/catch.
        do {
            // Simulamos delay de red para hacer el mock realista
            try await Task.sleep(nanoseconds: 800_000_000) // 0.8 segundos
            
            // En el Paso 7 esto será:
            // pendingAlerts = try await repository.getPendingAlerts(for: userID)
            pendingAlerts = [MockData.pendingAlert]
            recentTransactions = MockData.transactions
            beneficiaryAccounts = [MockData.beneficiaryAccount]
            spendingByCategory = MockData.spendingByCategory
            
        } catch {
            errorMessage = "No pudimos cargar tu dashboard. Intentá de nuevo."
        }
        
        isLoading = false
    }
    
    // MARK: - Actions
    
    // CONCEPTO: async throws — puede fallar Y es asíncrona
    func resolveAlert(_ alert: RiskAlert, status: AlertStatus) async {
        // Optimistic update: actualizamos la UI antes de confirmar con el servidor
        // Esto hace la app sentirse instantánea (patrón común en fintechs)
        pendingAlerts.removeAll { $0.id == alert.id }
        
        // En Paso 7: try await repository.resolveAlert(alertID: alert.id, status: status)
    }
}

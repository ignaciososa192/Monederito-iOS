//
//  NotificationPreferencesView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 19/04/2026.
//

import SwiftUI

struct NotificationPreferencesView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage(UserPreferences.Keys.notificationsEnabled)
    private var notificationsEnabled: Bool = UserPreferences.defaultNotifications
    
    @State private var riskAlerts: Bool = true
    @State private var transactionAlerts: Bool = true
    @State private var budgetAlerts: Bool = true
    @State private var educationTips: Bool = true
    @State private var weeklySummary: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.monederitoBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // Master toggle
                    masterToggleSection
                    
                    Divider()
                        .padding(.leading, 20)
                    
                    // Detailed preferences
                    ScrollView {
                        VStack(spacing: 20) {
                            
                            Text("Tipos de notificaciones")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 12) {
                                notificationToggleRow(
                                    icon: "exclamationmark.triangle.fill",
                                    iconColor: Color.riskRed,
                                    title: "Alertas de riesgo",
                                    subtitle: "Gastos que requieren tu aprobación",
                                    isOn: $riskAlerts
                                )
                                
                                notificationToggleRow(
                                    icon: "creditcard.fill",
                                    iconColor: Color.monederitoOrange,
                                    title: "Alertas de transacciones",
                                    subtitle: "Notificaciones de cada compra",
                                    isOn: $transactionAlerts
                                )
                                
                                notificationToggleRow(
                                    icon: "chart.pie.fill",
                                    iconColor: Color.monederitoPurple,
                                    title: "Alertas de presupuesto",
                                    subtitle: "Cuando se acerca al límite mensual",
                                    isOn: $budgetAlerts
                                )
                                
                                notificationToggleRow(
                                    icon: "book.fill",
                                    iconColor: Color.safeGreen,
                                    title: "Tips educativos",
                                    subtitle: "Consejos financieros personalizados",
                                    isOn: $educationTips
                                )
                                
                                notificationToggleRow(
                                    icon: "calendar.fill",
                                    iconColor: Color.warningAmber,
                                    title: "Resumen semanal",
                                    subtitle: "Reporte de gastos de la semana",
                                    isOn: $weeklySummary
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 24)
                    }
                }
            }
            .navigationTitle("Preferencias de notificaciones")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundColor(Color.monederitoOrange)
                }
            }
        }
    }
    
    @ViewBuilder
    private var masterToggleSection: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(notificationsEnabled ? Color.safeGreen.opacity(0.15) : Color.gray.opacity(0.1))
                    .frame(width: 56, height: 56)
                Image(systemName: notificationsEnabled ? "bell.fill" : "bell.slash.fill")
                    .font(.title2)
                    .foregroundColor(notificationsEnabled ? Color.safeGreen : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Notificaciones")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
                Text(notificationsEnabled ? "Activadas" : "Desactivadas")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Toggle("", isOn: $notificationsEnabled)
                .labelsHidden()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
    }
    
    @ViewBuilder
    private func notificationToggleRow(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
                .disabled(!notificationsEnabled)
                .opacity(notificationsEnabled ? 1 : 0.5)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    NotificationPreferencesView()
}

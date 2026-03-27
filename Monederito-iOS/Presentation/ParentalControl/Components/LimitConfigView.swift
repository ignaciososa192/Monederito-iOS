//
//  LimitConfigView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 27/03/2026.
//

import SwiftUI

// Vista de configuración de límites
// CONCEPTO: @Binding — permite que esta View modifique
// una variable que VIVE en la View padre.
// Es la forma de comunicación hijo → padre en SwiftUI.

struct LimitConfigView: View {
    
    // CONCEPTO: @Binding
    // No es una copia — es una REFERENCIA al valor del padre.
    // Cuando lo modificamos acá, se modifica en el padre también.
    @Binding var account: BeneficiaryAccount
    let onSave: (Double, Double) -> Void
    
    @State private var dailyLimit: Double
    @State private var monthlyLimit: Double
    @Environment(\.dismiss) private var dismiss
    
    init(account: Binding<BeneficiaryAccount>, onSave: @escaping (Double, Double) -> Void) {
        self._account = account
        self.onSave = onSave
        // Inicializamos @State con los valores actuales
        self._dailyLimit = State(initialValue: account.wrappedValue.dailyLimit)
        self._monthlyLimit = State(initialValue: account.wrappedValue.monthlyLimit)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Info card
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(Color.monederitoOrange)
                        Text("Los límites se aplican en tiempo real. Lucas recibirá una notificación cuando se actualicen.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(14)
                    .background(Color.monederitoOrange.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    
                    // Límite diario
                    limitSection(
                        title: "Límite Diario",
                        subtitle: "Máximo que puede gastar en un día",
                        icon: "sun.max.fill",
                        value: $dailyLimit,
                        step: 500,
                        range: 500...50000
                    )
                    
                    // Límite mensual
                    limitSection(
                        title: "Límite Mensual",
                        subtitle: "Máximo que puede gastar en el mes",
                        icon: "calendar",
                        value: $monthlyLimit,
                        step: 1000,
                        range: 1000...500000
                    )
                    
                    // Validación
                    if dailyLimit > monthlyLimit {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(Color.riskRed)
                            Text("El límite diario no puede superar el mensual")
                                .font(.caption)
                                .foregroundColor(Color.riskRed)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Botón guardar
                    Button {
                        onSave(dailyLimit, monthlyLimit)
                        dismiss()
                    } label: {
                        Text("Guardar cambios")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                dailyLimit <= monthlyLimit
                                ? Color.monederitoOrange
                                : Color.gray
                            )
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(dailyLimit > monthlyLimit)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color.monederitoBackground.ignoresSafeArea())
            .navigationTitle("Configurar Límites")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                        .foregroundColor(Color.monederitoOrange)
                }
            }
        }
    }
    
    @ViewBuilder
    private func limitSection(
        title: String,
        subtitle: String,
        icon: String,
        value: Binding<Double>,
        step: Double,
        range: ClosedRange<Double>
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(Color.monederitoOrange)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.black)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // Monto actual
            Text(formatAmount(value.wrappedValue))
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color.monederitoOrange)
                .frame(maxWidth: .infinity, alignment: .center)
            
            // Slider
            Slider(value: value, in: range, step: step)
                .tint(Color.monederitoOrange)
            
            // Min / Max
            HStack {
                Text(formatAmount(range.lowerBound))
                    .font(.caption2)
                    .foregroundColor(.gray)
                Spacer()
                Text(formatAmount(range.upperBound))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
        .padding(.horizontal)
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0
        formatter.locale = Locale(identifier: "es_AR")
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
    }
}

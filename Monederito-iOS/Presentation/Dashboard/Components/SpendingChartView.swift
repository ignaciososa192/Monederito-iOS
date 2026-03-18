//
//  SpendingChartView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 17/03/2026.
//

import SwiftUI
import Charts

struct SpendingChartView: View {
    
    let chartData: [(category: TransactionCategory, amount: Double)]
    let total: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Header
            HStack {
                Text("Gastos del mes")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                Spacer()
                Text(formatAmount(total))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }
            
            if chartData.isEmpty {
                Text("Sin movimientos este mes")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                
                // Donut centrado
                Chart(chartData, id: \.category) { item in
                    SectorMark(
                        angle: .value("Monto", item.amount),
                        innerRadius: .ratio(0.6),
                        angularInset: 2
                    )
                    .foregroundStyle(colorFor(item.category))
                    .cornerRadius(4)
                }
                .chartLegend(.hidden)
                .frame(height: 180)
                .frame(maxWidth: .infinity)
                .chartBackground { _ in
                    VStack(spacing: 2) {
                        Text("Total")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                        Text(formatAmount(total))
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                }

                // Leyenda debajo — una fila por categoría
                VStack(spacing: 10) {
                    ForEach(chartData.prefix(6), id: \.category) { item in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(colorFor(item.category))
                                .frame(width: 10, height: 10)
                            
                            Text("\(item.category.emoji) \(item.category.rawValue)")
                                .font(.caption)
                                .foregroundColor(.black)  // ← foregroundColor en vez de foregroundStyle
                                .frame(minWidth: 80, alignment: .leading)
                            
                            Spacer()
                            
                            Text(formatAmount(item.amount))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(
                                    item.category.isRisky ? .red : .black
                                )
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
    
    private func colorFor(_ category: TransactionCategory) -> Color {
        switch category {
        case .gambling:         return Color.riskRed
        case .highRiskInvest:   return Color.riskRed.opacity(0.7)
        case .food:             return Color.monederitoOrange
        case .transport:        return Color.monederitoPurple
        case .entertainment:    return Color.warningAmber
        case .education:        return Color.safeGreen
        case .services:         return Color.monederitoOrange.opacity(0.4)
        default:                return Color.gray.opacity(0.4)
        }
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

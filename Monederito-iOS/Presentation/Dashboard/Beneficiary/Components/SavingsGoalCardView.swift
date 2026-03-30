//
//  SavingsGoalCardView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 30/03/2026.
//

import SwiftUI

struct SavingsGoalCardView: View {
    
    let goal: SavingsGoal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Header
            HStack {
                Text(goal.emoji)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(goal.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    
                    Text("\(goal.progressPercentage)% completado")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if goal.isCompleted {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(Color.safeGreen)
                        .font(.title3)
                }
            }
            
            // Barra de progreso
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.12))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .foregroundStyle(
                            goal.isCompleted
                            ? AnyShapeStyle(Color.safeGreen)
                            : AnyShapeStyle(LinearGradient(
                                colors: [Color.monederitoOrange, Color.monederitoPurple],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                        )
                        .frame(width: geo.size.width * goal.progressRatio, height: 8)
                        // CONCEPTO: animation con valor — se anima cuando cambia progressRatio
                        .animation(.spring(duration: 0.6), value: goal.progressRatio)
                }
            }
            .frame(height: 8)
            
            // Montos
            HStack {
                Text(goal.formattedCurrent)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Color.monederitoOrange)
                
                Spacer()
                
                Text("Meta: \(goal.formattedTarget)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
        .overlay(
            // Borde verde si está completada
            RoundedRectangle(cornerRadius: 14)
                .stroke(goal.isCompleted ? Color.safeGreen.opacity(0.4) : .clear, lineWidth: 1.5)
        )
    }
}

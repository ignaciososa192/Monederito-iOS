//
//  LessonCardView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 31/03/2026.
//

import SwiftUI

struct LessonCardView: View {
    
    let lesson: Lesson
    let onTap: () -> Void
    let onComplete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Header
            HStack {
                categoryIcon
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(lesson.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .lineLimit(2)
                    
                    Text(lesson.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                
                Spacer()
                
                if lesson.isCompleted {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(Color.safeGreen)
                        .font(.title3)
                }
            }
            
            // Metadata
            HStack {
                difficultyBadge
                
                Spacer()
                
                durationLabel
                
                if !lesson.isCompleted {
                    Spacer()
                    
                    Button(action: onComplete) {
                        Text("Completar")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.monederitoOrange)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
        .padding(14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(lesson.isCompleted ? Color.safeGreen.opacity(0.4) : .clear, lineWidth: 1.5)
        )
        .frame(width: 280, height: 160) // FIXED: Ensures consistent card size
        .onTapGesture {
            onTap()
        }
    }
    
    // MARK: - Computed Properties
    
    @ViewBuilder
    private var categoryIcon: some View {
        switch lesson.category {
        case .digitalSafety:
            Image(systemName: "shield.lefthalf.filled")
                .foregroundColor(Color.riskRed)
        case .financialLiteracy:
            Image(systemName: "dollarsign.circle.fill")
                .foregroundColor(Color.monederitoOrange)
        case .responsibleSpending:
            Image(systemName: "chart.pie.fill")
                .foregroundColor(Color.monederitoPurple)
        case .fraudPrevention:
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(Color.warningAmber)
        }
    }
    
    @ViewBuilder
    private var difficultyBadge: some View {
        Text(lesson.difficulty.rawValue)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundColor(difficultyColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(difficultyColor.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
    
    @ViewBuilder
    private var durationLabel: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock.fill")
                .font(.caption2)
                .foregroundColor(.gray)
            
            Text(formatDuration(lesson.estimatedDuration))
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
    
    // MARK: - Helper Properties
    
    private var difficultyColor: Color {
        switch lesson.difficulty {
        case .beginner:
            return Color.safeGreen
        case .intermediate:
            return Color.warningAmber
        case .advanced:
            return Color.riskRed
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration / 60)
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return remainingMinutes > 0 ? "\(hours)h \(remainingMinutes)m" : "\(hours)h"
        }
    }
}

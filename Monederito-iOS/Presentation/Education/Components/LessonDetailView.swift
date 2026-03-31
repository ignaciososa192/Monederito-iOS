//
//  LessonDetailView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 31/03/2026.
//

import SwiftUI

struct LessonDetailView: View {
    
    let lesson: Lesson
    let onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text(lesson.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        Text(lesson.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        HStack {
                            difficultyBadge
                            Spacer()
                            durationLabel
                        }
                    }
                    .padding(.bottom, 8)
                    
                    // Content
                    Text(lesson.content)
                        .font(.body)
                        .foregroundColor(.black)
                        .lineSpacing(4)
                    
                    if !lesson.isCompleted {
                        Button(action: {
                            onComplete()
                            dismiss()
                        }) {
                            Text("Marcar como Completada")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.monederitoOrange)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.top, 20)
                    }
                }
                .padding(20)
            }
            .background(Color.monederitoBackground.ignoresSafeArea())
            .navigationTitle("Lección")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    @ViewBuilder
    private var difficultyBadge: some View {
        Text(lesson.difficulty.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(difficultyColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(difficultyColor.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    @ViewBuilder
    private var durationLabel: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock.fill")
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(formatDuration(lesson.estimatedDuration))
                .font(.caption)
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

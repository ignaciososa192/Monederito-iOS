//
//  EducationBlockingStrategy.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 31/03/2026.
//

import Foundation

final class EducationBlockingStrategy: PaymentBlockingStrategy {
    private let educationRepository: EducationRepositoryProtocol
    private var digitalSafetyLessonID: UUID?
    
    init(educationRepository: EducationRepositoryProtocol) {
        self.educationRepository = educationRepository
        Task {
            await loadDigitalSafetyLessonID()
        }
    }
    
    private func loadDigitalSafetyLessonID() async {
        do {
            let lessons = try await educationRepository.fetchLessons()
            if let digitalSafetyLesson = lessons.first(where: { $0.category == .digitalSafety }) {
                digitalSafetyLessonID = digitalSafetyLesson.id
            }
        } catch {
            // Handle error appropriately
            print("Error loading digital safety lesson ID: \(error)")
        }
    }
    
    func shouldBlockTransaction(transaction: Transaction, userProgress: UserProgress) -> BlockingDecision {
        // Check if transaction is high-risk using existing isRisky property
        guard transaction.isRisky || transaction.amount > 100.0 else {
            return BlockingDecision(
                shouldBlock: false,
                reason: nil,
                requiredLessons: []
            )
        }
        
        // Check if user completed Digital Safety lesson
        let digitalSafetyCompleted: Bool
        if let lessonID = digitalSafetyLessonID {
            digitalSafetyCompleted = userProgress.completedLessons.contains(lessonID)
        } else {
            // Fallback: check if any completed lesson has digital safety category
            digitalSafetyCompleted = false // Will be updated asynchronously
        }
        
        if digitalSafetyCompleted {
            return BlockingDecision(
                shouldBlock: false,
                reason: nil,
                requiredLessons: []
            )
        } else {
            return BlockingDecision(
                shouldBlock: true,
                reason: "High-risk transaction requires completion of Digital Safety lesson",
                requiredLessons: [
                    Lesson(
                        id: UUID(),
                        title: "Seguridad Digital",
                        description: "Aprende a protegerte contra fraudes y estafas online",
                        content: "Comprehensive digital safety content...",
                        category: .digitalSafety,
                        difficulty: .beginner,
                        estimatedDuration: 1800,
                        isCompleted: false,
                        completionDate: nil
                    )
                ]
            )
        }
    }
}

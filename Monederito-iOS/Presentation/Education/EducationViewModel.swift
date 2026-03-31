//
//  EducationViewModel.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 31/03/2026.
//
 
import SwiftUI
 
@Observable
class EducationViewModel {
    
    // MARK: - Dependencies
    private let educationRepository: EducationRepositoryProtocol
    private let educationBlockingStrategy: EducationBlockingStrategy
    private let userId: UUID
    
    // MARK: - State
    var lessons: [Lesson] = []
    var userProgress: UserProgress?
    var selectedLesson: Lesson?
    var isLoading: Bool = false
    
    // MARK: - Computed Properties
    var digitalSafetyLessons: [Lesson] {
        lessons.filter { $0.category == .digitalSafety }
    }
    
    var financialLiteracyLessons: [Lesson] {
        lessons.filter { $0.category == .financialLiteracy }
    }
    
    var responsibleSpendingLessons: [Lesson] {
        lessons.filter { $0.category == .responsibleSpending }
    }
    
    var fraudPreventionLessons: [Lesson] {
        lessons.filter { $0.category == .fraudPrevention }
    }
    
    var beginnerLessons: [Lesson] {
        lessons.filter { $0.difficulty == .beginner }
    }
    
    var intermediateLessons: [Lesson] {
        lessons.filter { $0.difficulty == .intermediate }
    }
    
    var advancedLessons: [Lesson] {
        lessons.filter { $0.difficulty == .advanced }
    }
    
    var completedLessons: [Lesson] {
        lessons.filter { $0.isCompleted }
    }
    
    var pendingLessons: [Lesson] {
        lessons.filter { !$0.isCompleted }
    }
    
    var completionProgress: Double {
        guard !lessons.isEmpty else { return 0.0 }
        let completedCount = lessons.filter { $0.isCompleted }.count
        return Double(completedCount) / Double(lessons.count)
    }
    
    var totalPoints: Int {
        userProgress?.totalPoints ?? 0
    }
    
    var currentLevel: LessonDifficulty {
        userProgress?.currentLevel ?? .beginner
    }
    
    // MARK: - Initialization
    init(
        educationRepository: EducationRepositoryProtocol,
        educationBlockingStrategy: EducationBlockingStrategy,
        userId: UUID
    ) {
        self.educationRepository = educationRepository
        self.educationBlockingStrategy = educationBlockingStrategy
        self.userId = userId
    }
    
    // MARK: - Load
    func loadData() async {
        isLoading = true
        
        do {
            try await Task.sleep(nanoseconds: 600_000_000)
            
            // For now, use MockEducationRepository data
            // In production, this would fetch from the repository
            if let mockRepo = educationRepository as? MockEducationRepository {
                async let lessonsTask = mockRepo.fetchLessons()
                async let progressTask = mockRepo.getUserProgress(userId: userId)
                
                let (fetchedLessons, fetchedProgress) = try await (lessonsTask, progressTask)
                
                self.lessons = fetchedLessons
                self.userProgress = fetchedProgress
            }
        } catch {
            print("Error cargando datos de educación: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Actions
    func markLessonCompleted(lessonId: UUID) async {
        do {
            try await educationRepository.markLessonCompleted(lessonId: lessonId, userId: userId)
            
            // Reload data to reflect changes
            await loadData()
        } catch {
            print("Error marcando lección como completada: \(error)")
        }
    }
    
    func selectLesson(_ lesson: Lesson) {
        selectedLesson = lesson
    }
    
    func canProceedWithTransaction(transaction: Transaction) -> BlockingDecision {
        guard let progress = userProgress else {
            return BlockingDecision(
                shouldBlock: true,
                reason: "Progreso de usuario no disponible",
                requiredLessons: []
            )
        }
        
        return educationBlockingStrategy.shouldBlockTransaction(
            transaction: transaction,
            userProgress: progress
        )
    }
}

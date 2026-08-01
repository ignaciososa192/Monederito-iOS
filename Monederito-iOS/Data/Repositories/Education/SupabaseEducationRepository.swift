//
//  SupabaseEducationRepository.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 19/04/2026.
//

import Foundation
import Supabase

final class SupabaseEducationRepository: EducationRepositoryProtocol {
    
    private let client: SupabaseClient
    
    init() {
        guard let client = SupabaseConfig.client else {
            fatalError("Supabase is not configured. Check SupabaseConfig.swift")
        }
        self.client = client
    }
    
    // MARK: - EducationRepositoryProtocol
    
    func fetchLessons() async throws -> [Lesson] {
        
        let response = try await client.from("lessons")
            .select()
            .order("created_at", ascending: true)
            .execute()
        
        let lessons: [SupabaseLesson] = try JSONDecoder().decode([SupabaseLesson].self, from: response.data)
        return lessons.map { $0.toLesson() }
    }
    
    func fetchLesson(by id: UUID) async throws -> Lesson? {
        
        let response = try await client.from("lessons")
            .select()
            .eq("id", value: id.uuidString)
            .single()
            .execute()
        
        let lesson: SupabaseLesson = try JSONDecoder().decode(SupabaseLesson.self, from: response.data)
        return lesson.toLesson()
    }
    
    func markLessonCompleted(lessonId: UUID, userId: UUID) async throws {
        
        // 1. Get current user progress
        let progress = try await getUserProgress(userId: userId)
        
        // 2. Only update if lesson not already completed
        if !progress.completedLessons.contains(lessonId) {
            // Build updated completed lessons as [String] to match Supabase column type
            let existingCompletedLessonIDs: [String] = progress.completedLessons.map { $0.uuidString }
            var updatedCompletedLessons: [String] = existingCompletedLessonIDs
            updatedCompletedLessons.append(lessonId.uuidString)
            
            // Compute new total points explicitly
            let newTotalPoints: Int = progress.totalPoints + 10
            
            // Perform update using an Encodable payload instead of [String: Any]
            struct UserProgressUpdatePayload: Encodable {
                let completed_lessons: [String]
                let total_points: Int
            }
            
            let payload = UserProgressUpdatePayload(
                completed_lessons: updatedCompletedLessons,
                total_points: newTotalPoints
            )
            
            _ = try await client
                .from("user_progress")
                .update(payload)
                .eq("user_id", value: userId.uuidString)
                .execute()
        }
    }
    
    func getUserProgress(userId: UUID) async throws -> UserProgress {
        
        let response = try await client.from("user_progress")
            .select()
            .eq("user_id", value: userId.uuidString)
            .single()
            .execute()
        
        let progress: SupabaseUserProgress = try JSONDecoder().decode(SupabaseUserProgress.self, from: response.data)
        
        // Fetch achievements if there are any
        var achievementObjects: [Achievement] = []
        if let achievementUUIDs = progress.achievements, !achievementUUIDs.isEmpty {
            let achievementsResponse = try await client.from("achievements")
                .select()
                .in("id", values: achievementUUIDs)
                .execute()
            
            let achievements: [SupabaseAchievement] = try JSONDecoder().decode([SupabaseAchievement].self, from: achievementsResponse.data)
            achievementObjects = achievements.map { $0.toAchievement() }
        }
        
        return UserProgress(
            userId: UUID(uuidString: progress.userID) ?? UUID(),
            completedLessons: progress.completedLessons.compactMap { UUID(uuidString: $0) },
            currentLevel: LessonDifficulty(rawValue: progress.currentLevel) ?? .beginner,
            totalPoints: progress.totalPoints,
            achievements: achievementObjects
        )
    }
}

// MARK: - DTOs for Supabase

struct SupabaseLesson: Codable {
    let id: String
    let title: String
    let description: String
    let content: String
    let category: String
    let difficulty: String
    let estimatedDuration: TimeInterval
    let isCompleted: Bool
    let completionDate: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case content
        case category
        case difficulty
        case estimatedDuration = "estimated_duration"
        case isCompleted     = "is_completed"
        case completionDate  = "completion_date"
    }
    
    func toLesson() -> Lesson {
        let dateFormatter = ISO8601DateFormatter()
        return Lesson(
            id: UUID(uuidString: id) ?? UUID(),
            title: title,
            description: description,
            content: content,
            category: LessonCategory(rawValue: category) ?? .financialLiteracy,
            difficulty: LessonDifficulty(rawValue: difficulty) ?? .beginner,
            estimatedDuration: estimatedDuration,
            isCompleted: isCompleted,
            completionDate: completionDate != nil ? dateFormatter.date(from: completionDate!) : nil
        )
    }
}

struct SupabaseUserProgress: Codable {
    let userID: String
    let completedLessons: [String]
    let currentLevel: String
    let totalPoints: Int
    let achievements: [String]? // UUID array instead of nested objects
    
    enum CodingKeys: String, CodingKey {
        case userID          = "user_id"
        case completedLessons = "completed_lessons"
        case currentLevel    = "current_level"
        case totalPoints     = "total_points"
        case achievements
    }
}

struct SupabaseAchievement: Codable {
    let id: String
    let title: String
    let description: String
    let unlockedDate: String
    let points: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case unlockedDate   = "unlocked_date"
        case points
    }
    
    func toAchievement() -> Achievement {
        let dateFormatter = ISO8601DateFormatter()
        return Achievement(
            id: UUID(uuidString: id) ?? UUID(),
            title: title,
            description: description,
            unlockedDate: dateFormatter.date(from: unlockedDate) ?? Date(),
            points: points
        )
    }
}

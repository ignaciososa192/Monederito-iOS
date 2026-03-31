//
//  EducationRepositoryProtocol.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 31/03/2026.
//

import Foundation

protocol EducationRepositoryProtocol {
    func fetchLessons() async throws -> [Lesson]
    func fetchLesson(by id: UUID) async throws -> Lesson?
    func markLessonCompleted(lessonId: UUID, userId: UUID) async throws
    func getUserProgress(userId: UUID) async throws -> UserProgress
}

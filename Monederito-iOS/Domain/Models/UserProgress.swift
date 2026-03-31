//
//  UserProgress.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 31/03/2026.
//

import Foundation

struct UserProgress {
    let userId: UUID
    var completedLessons: [UUID]
    var currentLevel: LessonDifficulty
    var totalPoints: Int
    var achievements: [Achievement]
}

struct Achievement {
    let id: UUID
    let title: String
    let description: String
    let unlockedDate: Date
    let points: Int
}

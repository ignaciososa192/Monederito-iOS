//
//  Lesson.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 31/03/2026.
//

import Foundation

struct Lesson: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let content: String
    let category: LessonCategory
    let difficulty: LessonDifficulty
    let estimatedDuration: TimeInterval
    var isCompleted: Bool
    let completionDate: Date?
}

enum LessonCategory: String, CaseIterable, Codable {
    case digitalSafety = "Digital Safety"
    case financialLiteracy = "Financial Literacy"
    case responsibleSpending = "Responsible Spending"
    case fraudPrevention = "Fraud Prevention"
}

enum LessonDifficulty: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
}

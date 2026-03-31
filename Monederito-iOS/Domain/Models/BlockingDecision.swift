//
//  BlockingDecision.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 31/03/2026.
//

import Foundation

struct BlockingDecision {
    let shouldBlock: Bool
    let reason: String?
    let requiredLessons: [Lesson]
}

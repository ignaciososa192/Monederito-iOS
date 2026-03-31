//
//  MockEducationRepository.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 31/03/2026.
//

import Foundation

final class MockEducationRepository: EducationRepositoryProtocol {
    private var mockLessons: [Lesson] = []
    private var mockUserProgress: [UUID: UserProgress] = [:]
    
    init() {
        setupMockData()
    }
    
    private func delay() async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
    }
    
    func fetchLessons() async throws -> [Lesson] {
        try await delay()
        return mockLessons
    }
    
    func fetchLesson(by id: UUID) async throws -> Lesson? {
        try await delay()
        return mockLessons.first { $0.id == id }
    }
    
    func markLessonCompleted(lessonId: UUID, userId: UUID) async throws {
        try await delay()
        
        if var progress = mockUserProgress[userId] {
            if !progress.completedLessons.contains(lessonId) {
                progress.completedLessons.append(lessonId)
                progress.totalPoints += 10
                mockUserProgress[userId] = progress
            }
        }
        
        // Mark lesson as completed in mock data
        if let index = mockLessons.firstIndex(where: { $0.id == lessonId }) {
            mockLessons[index] = Lesson(
                id: mockLessons[index].id,
                title: mockLessons[index].title,
                description: mockLessons[index].description,
                content: mockLessons[index].content,
                category: mockLessons[index].category,
                difficulty: mockLessons[index].difficulty,
                estimatedDuration: mockLessons[index].estimatedDuration,
                isCompleted: true,
                completionDate: Date()
            )
        }
    }
    
    func getUserProgress(userId: UUID) async throws -> UserProgress {
        try await delay()
        return mockUserProgress[userId] ?? UserProgress(
            userId: userId,
            completedLessons: [],
            currentLevel: .beginner,
            totalPoints: 0,
            achievements: []
        )
    }
    
    private func setupMockData() {
        let digitalSafetyLesson = Lesson(
            id: UUID(),
            title: "Seguridad Digital",
            description: "Aprende a protegerte contra fraudes y estafas online",
            content: """
            ## Seguridad Digital en Transacciones
            
            Aprende a protegerte contra fraudes y estafas online.
            
            ### Señales de alerta:
            - 🚨 Ofertas "demasiado buenas para ser verdad"
            - 🔗 URLs sospechosas o acortadas
            - 📧 Emails no solicitados pidiendo datos personales
            - ⏰ Presión para actuar "inmediatamente"
            
            ### Consejos de seguridad:
            1. **Verifica siempre**: Confirma la identidad del vendedor
            2. **Usa métodos seguros**: Tarjetas de crédito con protección
            3. **Mantén actualizado**: Software y antivirus al día
            4. **Desconfía**: Si algo suena raro, probablemente lo es
            
            ### Qué hacer si sospechas fraude:
            1. Contactá tu banco inmediatamente
            2. Cambiá tus contraseñas
            3. Reportá la plataforma
            4. Monitoreá tus cuentas regularmente
            
            > "La mejor defensa es la prevención y la educación"
            """,
            category: .digitalSafety,
            difficulty: .beginner,
            estimatedDuration: 1800,
            isCompleted: false,
            completionDate: nil
        )
        
        mockLessons = [
            digitalSafetyLesson,
            Lesson(
                id: UUID(),
                title: "Presupuesto Mensual",
                description: "Aprende a organizar tus ingresos y gastos de forma mensual",
                content: """
                ## Presupuesto Mensual
                
                Aprende a organizar tus ingresos y gastos de forma mensual.
                
                ### Pasos básicos:
                1. **Lista tus ingresos**: Anota todo el dinero que recibes
                2. **Registra tus gastos**: Divide en fijos y variables
                3. **Establece límites**: Define máximos para cada categoría
                4. **Revisa semanalmente**: Ajusta según sea necesario
                
                ### Consejo clave:
                > "Un buen presupuesto no es restrictivo, es liberador"
                """,
                category: .financialLiteracy,
                difficulty: .beginner,
                estimatedDuration: 2400,
                isCompleted: false,
                completionDate: nil
            ),
            Lesson(
                id: UUID(),
                title: "Ahorro Automático",
                description: "Configura transferencias automáticas para ahorrar sin esfuerzo",
                content: """
                ## Ahorro Automático
                
                Configura transferencias automáticas para ahorrar sin esfuerzo.
                
                ### Beneficios:
                - **Consistencia**: Ahorras todos los meses
                - **Disciplina**: Elimina la tentación de gastar
                - **Crecimiento**: Tu dinero trabaja para ti
                
                ### Cómo empezar:
                1. Define un monto fijo mensual
                2. Programa la transferencia el día que cobras
                3. Trátalo como un gasto fijo más
                
                ### Regla de oro:
                > "Págate a ti primero antes que a cualquier otro"
                """,
                category: .financialLiteracy,
                difficulty: .intermediate,
                estimatedDuration: 1800,
                isCompleted: false,
                completionDate: nil
            )
        ]
        
        // Set up mock user progress
        mockUserProgress[UUID()] = UserProgress(
            userId: UUID(),
            completedLessons: [],
            currentLevel: .beginner,
            totalPoints: 0,
            achievements: []
        )
    }
}

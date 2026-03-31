//
//  EducationView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 31/03/2026.
//

import SwiftUI

struct EducationView: View {
    
    @Environment(AppState.self) private var appState
    @State private var viewModel: EducationViewModel
    
    init(viewModel: EducationViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                
                // Progress Header Card
                progressHeaderSection
                
                // Pending Lessons
                if !viewModel.pendingLessons.isEmpty {
                    pendingLessonsSection
                }
                
                // Digital Safety Lessons
                if !viewModel.digitalSafetyLessons.isEmpty {
                    digitalSafetySection
                }
            }
            .padding(.vertical)
        }
        .background(Color.monederitoBackground.ignoresSafeArea())
        .navigationTitle("Educación Financiera")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadData()
        }
        .overlay {
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.1).ignoresSafeArea()
                    ProgressView()
                        .tint(Color.monederitoPurple)
                        .padding(24)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
        .sheet(item: $viewModel.selectedLesson) { lesson in
            LessonDetailView(
                lesson: lesson,
                onComplete: {
                    Task {
                        await viewModel.markLessonCompleted(lessonId: lesson.id)
                    }
                }
            )
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var progressHeaderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tu Progreso 📚")
                .font(.headline)
                .padding(.horizontal)
            
            HStack(spacing: 12) {
                progressCard(
                    title: "Puntos",
                    value: "\(viewModel.totalPoints)",
                    icon: "star.fill",
                    color: Color.monederitoOrange
                )
                
                progressCard(
                    title: "Nivel",
                    value: viewModel.currentLevel.rawValue,
                    icon: "chart.line.uptrend.xyaxis",
                    color: Color.monederitoPurple
                )
                
                progressCard(
                    title: "Progreso",
                    value: "\(Int(viewModel.completionProgress * 100))%",
                    icon: "checkmark.circle.fill",
                    color: Color.safeGreen
                )
            }
            .padding(.horizontal)
            
            // Overall Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                Text("Progreso General")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray.opacity(0.12))
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 6)
                            .foregroundStyle(LinearGradient(
                                colors: [Color.monederitoOrange, Color.monederitoPurple],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: geo.size.width * viewModel.completionProgress, height: 12)
                            .animation(.spring(duration: 0.6), value: viewModel.completionProgress)
                    }
                }
                .frame(height: 12)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private func progressCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
    
    @ViewBuilder
    private var pendingLessonsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Lecciones Pendientes 📖")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.pendingLessons.count) lecciones")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
                
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 12) { // FIXED: Added alignment and consistent spacing
                    ForEach(viewModel.pendingLessons) { lesson in
                        LessonCardView(
                            lesson: lesson,
                            onTap: {
                                viewModel.selectLesson(lesson)
                            },
                            onComplete: {
                                Task {
                                    await viewModel.markLessonCompleted(lessonId: lesson.id)
                                }
                            }
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    }
                }
                .padding(.horizontal)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.pendingLessons.count)
            }
        }
    }
    
    @ViewBuilder
    private var digitalSafetySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Seguridad Digital 🔒")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.digitalSafetyLessons.count) lecciones")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
                
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 12) { // FIXED: Added alignment and consistent spacing
                    ForEach(viewModel.digitalSafetyLessons) { lesson in
                        LessonCardView(
                            lesson: lesson,
                            onTap: {
                                viewModel.selectLesson(lesson)
                            },
                            onComplete: {
                                Task {
                                    await viewModel.markLessonCompleted(lessonId: lesson.id)
                                }
                            }
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    }
                }
                .padding(.horizontal)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.digitalSafetyLessons.count)
            }
        }
    }
}


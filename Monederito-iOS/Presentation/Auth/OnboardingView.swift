//
//  OnboardingView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 27/03/2026.
//

import SwiftUI

struct OnboardingView: View {
    
    @Binding var showOnboarding: Bool
    @State private var currentPage: Int = 0
    
    struct OnboardingPage {
        let icon: String
        let title: String
        let description: String
        let color: Color
    }
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "shield.fill",
            title: "Protección inteligente",
            description: "Detectamos gastos de riesgo en tiempo real y te avisamos antes de que ocurran. Vos decidís con un tap.",
            color: Color.monederitoOrange
        ),
        OnboardingPage(
            icon: "chart.pie.fill",
            title: "Control total",
            description: "Visualizá todos los gastos de tu familia en un dashboard claro. Configurá límites diarios y mensuales.",
            color: Color.monederitoPurple
        ),
        OnboardingPage(
            icon: "book.fill",
            title: "Educación financiera",
            description: "Cada alerta viene con un tip educativo. Enseñá hábitos financieros sanos sin ser el 'policía malo'.",
            color: Color.safeGreen
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Skip button
            HStack {
                Spacer()
                Button("Omitir") {
                    showOnboarding = false
                }
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding()
            }
            
            // Páginas
            TabView(selection: $currentPage) {
                ForEach(pages.indices, id: \.self) { index in
                    pageView(pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
            
            // Indicadores de página
            HStack(spacing: 8) {
                ForEach(pages.indices, id: \.self) { index in
                    Capsule()
                        .fill(currentPage == index
                              ? pages[currentPage].color
                              : Color.gray.opacity(0.3))
                        .frame(width: currentPage == index ? 24 : 8, height: 8)
                        .animation(.spring(duration: 0.3), value: currentPage)
                }
            }
            .padding(.bottom, 32)
            
            // Botón acción
            Button {
                if currentPage < pages.count - 1 {
                    withAnimation { currentPage += 1 }
                } else {
                    showOnboarding = false
                }
            } label: {
                HStack {
                    Text(currentPage < pages.count - 1 ? "Siguiente" : "Comenzar")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(pages[currentPage].color)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color.monederitoBackground.ignoresSafeArea())
    }
    
    @ViewBuilder
    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: 32) {
            
            Spacer()
            
            // Ícono animado
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.12))
                    .frame(width: 160, height: 160)
                Circle()
                    .fill(page.color.opacity(0.2))
                    .frame(width: 120, height: 120)
                Image(systemName: page.icon)
                    .font(.system(size: 60))
                    .foregroundColor(page.color)
            }
            
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
    }
}

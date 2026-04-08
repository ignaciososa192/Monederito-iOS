//
//  BeneficiaryTabView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 16/03/2026.
//

import SwiftUI

enum BeneficiaryTab {
    case wallet, operations, activity, savings, education
}

struct BeneficiaryTabView: View {
    
    @Environment(AppState.self) private var appState
    @Environment(DependencyContainer.self) private var container
    @State private var selectedTab: BeneficiaryTab = .wallet
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            NavigationStack {
                BeneficiaryDashboardView()
            }
            .tabItem {
                Label("Billetera", systemImage: "wallet.pass.fill")
            }
            .tag(BeneficiaryTab.wallet)
            
            NavigationStack {
                OperationsMainView()
            }
            .tabItem {
                Label("Operaciones", systemImage: "arrow.left.arrow.right.circle.fill")
            }
            .tag(BeneficiaryTab.operations)
            
            NavigationStack {
                PlaceholderView(title: "Actividad", icon: "list.bullet.rectangle")
                    .navigationTitle("Actividad")
            }
            .tabItem {
                Label("Actividad", systemImage: "list.bullet.rectangle")
            }
            .tag(BeneficiaryTab.activity)
            
            NavigationStack {
                PlaceholderView(title: "Mis Metas", icon: "star.fill")
                    .navigationTitle("Mis Metas")
            }
            .tabItem {
                Label("Metas", systemImage: "star.fill")
            }
            .tag(BeneficiaryTab.savings)
            
            NavigationStack {
                EducationView(viewModel: EducationViewModel(
                    educationRepository: container.educationRepository,
                    educationBlockingStrategy: EducationBlockingStrategy(
                        educationRepository: container.educationRepository
                    ),
                    userId: appState.currentUser?.id ?? UUID()
                ))
            }
            .tabItem {
                Label("Aprender", systemImage: "book.fill")
            }
            .tag(BeneficiaryTab.education)
        }
        .tint(Color.monederitoPurple)
        // Deep link desde AppState — sin NotificationCenter
        .onChange(of: appState.selectedBeneficiaryTab) { _, newTab in
            selectedTab = newTab
        }
    }
}

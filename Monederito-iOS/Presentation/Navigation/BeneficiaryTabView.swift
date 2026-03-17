//
//  BeneficiaryTabView.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 16/03/2026.
//

import SwiftUI

struct BeneficiaryTabView: View {
    
    @State private var selectedTab: BeneficiaryTab = .wallet
    
    enum BeneficiaryTab {
        case wallet, activity, savings, education
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            NavigationStack {
                PlaceholderView(title: "Mi Billetera", icon: "wallet.pass.fill")
                    .navigationTitle("Mi Billetera")
            }
            .tabItem {
                Label("Billetera", systemImage: "wallet.pass.fill")
            }
            .tag(BeneficiaryTab.wallet)
            
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
                PlaceholderView(title: "Aprender", icon: "book.fill")
                    .navigationTitle("Educación")
            }
            .tabItem {
                Label("Aprender", systemImage: "book.fill")
            }
            .tag(BeneficiaryTab.education)
        }
        .tint(Color.monederitoPurple)
    }
}

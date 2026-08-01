//
//  MonederitoApp.swift
//  Monederito-iOS
//
//  Created by Ignacio Sosa on 06/03/2026.
//

import SwiftUI
import GoogleSignIn
import FirebaseCore
import FirebaseAppCheck
import FirebaseCrashlytics

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let providerFactory = MonederitoAppCheckFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        FirebaseApp.configure()
        // Initialize Crashlytics
        let crashlytics = Crashlytics.crashlytics()
        crashlytics.setCrashlyticsCollectionEnabled(true)
        
        // Configure Google Sign-In
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: SupabaseConfig.googleClientID)
        
        return true
    }
}

@main
struct MonederitoApp: App {
    
    // CONCEPTO: @State en el App struct
    // AppState vive aquí — es el nivel más alto de la app.
    // Al inyectarlo con .environment(), todas las Views hijas pueden accederlo.
    @State private var appState = AppState()
    @State private var notificationManager = NotificationManager.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // El container decide qué repositorios utilizar
    // Usa .current para detectar automáticamente el ambiente (DEBUG = mock, RELEASE = supabase)
    private let container = DependencyContainer.current
    private let notificationDelegate = NotificationDelegate()

    init() {
        //Config del delegate antes de iniciar la app
        notificationDelegate.transactionRepository = container.transactionRepository
        UNUserNotificationCenter.current().delegate = notificationDelegate
        NotificationManager.shared.setup()
        
        // Restore Google session on app launch
        Task {
            await restoreGoogleSession()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                // CONCEPTO: .environment() — inyección de dependencias de SwiftUI.
                // Cualquier View descendiente puede hacer @Environment(AppState.self)
                // para acceder a este mismo objeto.
                .environment(appState)
                .environment(container)
                .environment(notificationManager)
            // CONCEPTO: onAppear para pedir permisos al iniciar
                .task {
                    notificationDelegate.appState = appState
                    if !notificationManager.isAuthorized {
                        await notificationManager.requestAuthorization()
                    }
                    notificationManager.clearBadge()
                }
                .onChange(of: notificationManager.pendingDeepLink) { _, deepLink in
                    handleDeepLink(deepLink)
                }
            // In your root view
            .onOpenURL { url in
                // Handle Google Sign-In callbacks
                if GIDSignIn.sharedInstance.handle(url) { return }
                
                // Handle deep links for notifications
                handleIncomingURL(url)
            }
        }
    }
    
    private func restoreGoogleSession() async {
        // Intenta recuperar al usuario silenciosamente
        if let googleResult = await GoogleSignInManager.shared.restorePreviousSignIn() {
            print("Sesión de Google restaurada para: \(googleResult.email)")
            // TODO: If you want to auto-login with restored session, call authRepository.signInWithGoogle()
        }
    }
    
    private func handleIncomingURL(_ url: URL) {
        // Parse URL components for deep link handling
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host else {
            print("⚠️ Invalid deep link URL: \(url)")
            return
        }
        
        // Handle different deep link schemes
        switch host {
        case "alert":
            // monederito://alert/{alertID}
            if let alertIDString = components.path.components(separatedBy: "/").last,
               let alertID = UUID(uuidString: alertIDString) {
                handleDeepLink(.riskAlert(alertID: alertID))
            }
        case "transaction":
            // monederito://transaction
            handleDeepLink(.transaction)
        case "settings":
            // monederito://settings
            handleDeepLink(.settings)
        case "beneficiary":
            // monederito://beneficiary
            handleDeepLink(.beneficiary)
        default:
            print("⚠️ Unknown deep link host: \(host)")
        }
    }

    private func handleDeepLink(_ deepLink: DeepLink?) {
        guard let deepLink else { return }
        defer { notificationManager.pendingDeepLink = nil }

        switch deepLink {
        case .riskAlert(let alertID):
            appState.selectedBenefactorTab = .alerts
            appState.pendingAlertID = alertID
        
        case .transaction:
            appState.selectedBenefactorTab = .dashboard
        
        case .settings:
            appState.selectedBenefactorTab = .settings
        
        case .beneficiary:
            appState.selectedBenefactorTab = .beneficiaries
        }
    }
}


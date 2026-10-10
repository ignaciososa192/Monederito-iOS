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
        guard AppConfiguration.current?.environment == .sandbox else { return true }

        #if DEBUG
        let providerFactory = AppCheckDebugProviderFactory()
        #else
        let providerFactory = MonederitoAppCheckFactory()
        #endif
        AppCheck.setAppCheckProviderFactory(providerFactory)
        FirebaseApp.configure()
        // Initialize Crashlytics
        let crashlytics = Crashlytics.crashlytics()
        crashlytics.setCrashlyticsCollectionEnabled(true)
        crashlytics.setCustomValue("sandbox", forKey: "environment")
        FirebaseDiagnostics.runIfRequested()
        
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
    @Environment(\.scenePhase) private var scenePhase
    @State private var appState = AppState()
    @State private var notificationManager = NotificationManager.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // El container decide qué repositorios utilizar
    // El scheme selecciona Mock o Sandbox, tanto en Debug como en Release.
    private let container = DependencyContainer.current
    private let notificationDelegate = NotificationDelegate()

    init() {
        //Config del delegate antes de iniciar la app
        notificationDelegate.transactionRepository = container.transactionRepository
        UNUserNotificationCenter.current().delegate = notificationDelegate
        NotificationManager.shared.setup()
        
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if let error = AppConfiguration.startupError {
                    ContentUnavailableView("Configuración pendiente", systemImage: "gearshape", description: Text(error))
                } else {
                    RootView()
                }
            }
                // CONCEPTO: .environment() — inyección de dependencias de SwiftUI.
                // Cualquier View descendiente puede hacer @Environment(AppState.self)
                // para acceder a este mismo objeto.
                .environment(appState)
                .environment(container)
                .environment(notificationManager)
            // CONCEPTO: onAppear para pedir permisos al iniciar
                .task {
                    guard AppConfiguration.startupError == nil else { return }
                    await appState.restoreSession(using: container.authRepository)
                    notificationDelegate.appState = appState
                    if !notificationManager.isAuthorized {
                        await notificationManager.requestAuthorization()
                    }
                    notificationManager.clearBadge()
                }
                .task { await appState.observeSession(using: container.authRepository) }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active, AppConfiguration.startupError == nil {
                        Task { await appState.restoreSession(using: container.authRepository) }
                    }
                }
                .onChange(of: notificationManager.pendingDeepLink) { _, deepLink in
                    handleDeepLink(deepLink)
                }
            // In your root view
            .onOpenURL { url in
                if url.scheme == "monederito", url.host == "auth", ["/callback", "/recovery"].contains(url.path) {
                    Task { await appState.handleAuthCallback(url, using: container.authRepository) }
                    return
                }
                // Handle Google Sign-In callbacks
                if AppConfiguration.current?.environment == .sandbox,
                   GIDSignIn.sharedInstance.handle(url) { return }
                
                // Handle deep links for notifications
                handleIncomingURL(url)
            }
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
            appState.selectedBenefactorTab = .dashboard
        case "settings":
            // monederito://settings
            handleDeepLink(.settings)
        case "beneficiary":
            // monederito://beneficiary
            appState.selectedBenefactorTab = .beneficiaries
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


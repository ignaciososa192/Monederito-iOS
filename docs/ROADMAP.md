# Monederito iOS - Development Roadmap

## Product North Star
Monederito is a family fintech focused on delegated control, risk prevention, transparent spending, and embedded financial education.

## UX-Driven MVP Principles
- Benefactor-first experience
- Short, low-friction approval flows
- Clear risk alerts and history
- Education inside the product, not as an afterthought
- Accessibility for parents, tutors, and older adults
- SwiftUI-first, modular, scalable, and easy to connect to Supabase later

## Phase 1 — Core Foundation ✅
- [x] 1. Domain layer: models, enums, protocols
- [x] 2. Main navigation: NavigationStack, TabView, typed routes
- [x] 3. Benefactor dashboard
- [x] 4. Beneficiary dashboard
- [x] 5. Parental control foundation
- [x] 6. Data layer foundation (Supabase-ready)

## Phase 2 — Core Features (Completed) ✅
- [x] 7. Auth: Login, Register, Biometrics
- [x] 9. Alerts tab with full history
- [x] 10. Financial education + gamification
- [x] 11. Settings & Profile (UI built, core security/notification toggles active)
- [x] 12. Rich push notifications

## Phase 3 — Operations & Navigation Wiring (Completed) 
- [x] 8. Operations module: QR, transfers, top-ups, services
  - [x] Connect existing Operations views to the main app navigation
  - [x] Keep each operation isolated in its own ViewModel
  - [x] Maintain repository-based contracts

## Phase 4 — UX Tickets & Polish ✅
- [x] TICKET-01: Onboarding as the first screen
- [x] TICKET-02: Account type selection flow
- [x] TICKET-03: Sign in with Google integration
- [ ] TICKET-04: Final UX/UI review against wireframes (manual review task)
- [x] TICKET-05: Settings detail navigation (Wire Help Center, Privacy Policy, Terms, Notification Prefs links)

## Phase 5 — Backend Integration ✅
- [x] 13. Real Supabase connection
  - [x] Add Supabase SDK via SPM
  - [x] Configure Supabase credentials in SupabaseConfig.swift
  - [x] Implement SupabaseAuthRepository with TODO comments for SDK calls
  - [x] Implement SupabaseTransactionRepository with TODO comments
  - [x] Implement SupabaseOperationsRepository with TODO comments
  - [x] Implement SupabaseUserRepository with TODO comments
  - [x] Implement SupabaseEducationRepository with TODO comments
  - [x] Replace TODO comments with real Supabase SDK calls
  - [ ] Test authentication flow
  - [ ] Test data persistence

## Phase 6 — Google Sign-In Integration ✅
- [x] Add Google Sign-In SDK via SPM
  - Package URL: https://github.com/google/GoogleSignIn-iOS
  - Version: 7.0.0 or later
- [x] Update GoogleSignInButton to use official Google button
  - Replace custom button with GoogleSignInButton from GoogleSignInSwift
  - Configure scheme: .light, style: .wide, state: .disabled/.normal
  - Apply .frame(maxWidth: .infinity) to match app button dimensions
- [x] Configure Google Client ID in SupabaseConfig.swift
  - Added actual Google Client ID from Google Cloud Console
- [x] Update GoogleSignInManager.swift to use actual SDK
  - Implemented GIDSignIn.sharedInstance.signInWithPresenting()
  - Added getRootViewController() helper method
  - Implemented signOut() method
- [x] Configure Google Sign-In in MonederitoApp.swift
  - Added import GoogleSignIn
  - Added configureGoogleSignIn() in init()
  - Added .onOpenURL handler for OAuth redirect
- [x] Implement role selection for Google Sign-In
  - Created GoogleRoleSelectionView component for role selection before auth
  - Added role parameter to signInWithGoogle in AuthRepositoryProtocol
  - Updated SupabaseAuthRepository to pass role to profile creation
  - Updated AuthViewModel to use googleSelectedRole
  - Integrated role selection modal in LoginView
  - Updated RegisterView to pass selected role to Google auth
  - Fixed role fallback from .beneficiary to .benefactor
  - Added logic to update existing profile if role differs
- [x] Add logout button to BeneficiaryDashboardView
  - Matches benefactor dashboard functionality

## Phase 7 — Security & Biometrics ✅
- [x] Implement SecurityService protocol
  - Created SecurityServiceProtocol for biometric and keychain operations
  - Implemented SecurityService with LocalAuthentication framework
  - Added FaceID/TouchID authentication support
  - Implemented Keychain credential storage
- [x] Integrate biometric authentication into AuthRepository
  - Updated SupabaseAuthRepository with SecurityService dependency
  - Implemented enableBiometrics() method
  - Added biometric availability checks
- [x] Add security error types to AppError
  - Added biometricNotAvailable and authenticationFailed cases
  - Added localized error messages

## Phase 8 — Analytics Integration ✅
- [x] Implement AnalyticsService protocol
  - Created AnalyticsServiceProtocol for analytics abstraction
  - Implemented MockAnalyticsService for development
  - Implemented FirebaseAnalyticsService for production
- [x] Create AnalyticsManager for event tracking
  - Comprehensive event tracking for user actions
  - Transaction tracking (completed, blocked, approved)
  - Financial operations tracking (QR, transfers, recharges)
  - Education tracking (lessons started/completed)
  - Screen view tracking
  - User property management
- [x] Integrate analytics into DependencyContainer
  - Added analyticsService to DI container
  - Added analyticsManager to DI container
  - Environment-based service selection

## Design and Architecture Rules for Future Work
- Use SwiftUI only unless there is a clear architectural reason not to
- Prefer NavigationStack and typed route enums
- Keep MVVM as the presentation pattern
- Keep business rules inside services, repositories, or strategies
- Keep Views dumb and reusable
- Keep ViewModels small, testable, and isolated
- Use mock repositories and preview data for every new feature
- Build in micro-tickets to reduce token usage and avoid large rewrites
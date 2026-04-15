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

## Phase 4 — UX Tickets & Polish 
- [ ] TICKET-01: Onboarding as the first screen
- [ ] TICKET-02: Account type selection flow
- [ ] TICKET-03: Sign in with Google integration
- [ ] TICKET-04: Final UX/UI review against wireframes
- [ ] TICKET-05: Settings detail navigation (Wire Help Center, Privacy Policy, Terms, Notification Prefs links)

## Phase 5 — Backend Integration ⏳
- [ ] 13. Real Supabase connection

## Design and Architecture Rules for Future Work
- Use SwiftUI only unless there is a clear architectural reason not to
- Prefer NavigationStack and typed route enums
- Keep MVVM as the presentation pattern
- Keep business rules inside services, repositories, or strategies
- Keep Views dumb and reusable
- Keep ViewModels small, testable, and isolated
- Use mock repositories and preview data for every new feature
- Build in micro-tickets to reduce token usage and avoid large rewrites
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

## Current Project Status
- Completed: Core foundation (Steps 1-6)
- Completed: Auth (Step 7)
- In progress: Operations module (Step 8) — files exist, navigation wiring still pending
- Completed: Alerts tab with full history (Step 9)
- Completed: Financial education + gamification (Step 10)
- Next: Settings & Profile (Step 11)
- Next: Rich push notifications (Step 12)
- Next: Real Supabase integration (Step 13)
- Next: UX/UI final review and wireframe alignment (TICKET-04)

## Phase 1 — Core Foundation ✅
- [x] 1. Domain layer: models, enums, protocols
- [x] 2. Main navigation: NavigationStack, TabView, typed routes
- [x] 3. Benefactor dashboard
- [x] 4. Beneficiary dashboard
- [x] 5. Parental control foundation
- [x] 6. Data layer foundation (Supabase-ready)

## Phase 2 — Current Build ⏳
- [x] 7. Auth: Login, Register, Biometrics
- [ ] 8. Operations module: QR, transfers, top-ups, services
  - [ ] Connect Operations views to the app navigation
  - [ ] Keep each operation isolated in its own ViewModel
  - [ ] Maintain repository-based contracts for future Supabase integration
- [x] 9. Alerts tab with full history
- [x] 10. Financial education + gamification

## Phase 3 — Productization ⏳
- [ ] 11. Settings & Profile
- [x] 12. Rich push notifications
- [ ] 13. Real Supabase connection

## Phase 4 — UX Tickets ⏳
- [ ] TICKET-01. Onboarding as the first screen
- [ ] TICKET-02. Account type selection flow
- [ ] TICKET-03. Sign in with Google integration
- [ ] TICKET-04. Final UX/UI review against wireframes

## Design and Architecture Rules for Future Work
- Use SwiftUI only unless there is a clear architectural reason not to
- Prefer NavigationStack and typed route enums
- Keep MVVM as the presentation pattern
- Keep business rules inside services, repositories, or strategies
- Keep Views dumb and reusable
- Keep ViewModels small, testable, and isolated
- Use mock repositories and preview data for every new feature
- Build in micro-tickets to reduce token usage and avoid large rewrites

## Suggested Work Order
1. Wire Step 8 into navigation
2. Close TICKET-01 onboarding
3. Close TICKET-02 account type selection
4. Close TICKET-03 Google sign-in
5. Review the final UX/UI against the research
6. Prepare Step 11, Step 12, and Supabase integration

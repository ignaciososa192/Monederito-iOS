# Monederito — MVP Product Brief

**Status:** Living document
**Owner:** Product / Engineering
**Date:** 2026-08-12

## 1. Product thesis

Monederito is not initially a new payment wallet. The MVP validates a **financial protection and delegation layer** for a benefactor who supervises a beneficiary's spending.

The core promise is:

> Protect a family's finances without having to monitor every transaction manually.

The product differentiates through delegated control, risk alerts, selective approval, spending visibility and contextual financial education.

## 2. Primary user

**Benefactor** is the primary MVP user. The beneficiary exists as a supervised account/entity but does not require a complete first-class product experience in MVP.

Representative job-to-be-done:

> When a dependent attempts a potentially risky or out-of-policy transaction, I want Monederito to detect it and let me decide quickly, so I can protect their money without constant supervision.

## 3. Core loop

```text
Benefactor configures account/rules
        ↓
Beneficiary transaction is simulated/created
        ↓
Monederito evaluates limits/categories
        ↓
Allowed → transaction completed
Blocked / approval required → risk alert
        ↓
Benefactor receives notification
        ↓
Approve / reject / resolve
        ↓
Contextual feedback is recorded
```

This loop is the MVP. Everything else is secondary.

## 4. MVP scope

### P0 — must work

- Authentication with Supabase.
- Benefactor profile.
- Create/manage a beneficiary account.
- Monthly and daily limits.
- Allowed and blocked categories.
- Transaction creation using mock/sandbox data; no real money movement.
- Transaction status evaluation.
- Risk alert creation.
- Benefactor alert list/detail.
- Approve/reject/resolve alert.
- Push notification and deep link into the relevant alert.
- Basic dashboard with balance/activity/risk summary.
- Analytics for activation and the core protection loop.

### P1 — useful but not required for first beta

- Basic spending charts.
- Contextual educational tips attached to alerts.
- Beneficiary-facing transaction history.
- Savings goals.
- Basic financial education lessons.

### P2 — explicitly deferred

- Real payments.
- Bank/PSP integrations.
- Real transfers and QR payments.
- Real card issuance.
- Production KYC / DNI / facial verification.
- Fraud/AML infrastructure.
- Android client.
- Advanced gamification.
- Full beneficiary product experience.

## 5. Existing implementation to preserve

### iOS

The current iOS repository already contains meaningful infrastructure that should be reused rather than rewritten:

- SwiftUI application structure.
- App-level `AppState` and dependency container.
- Supabase Auth repository.
- Email/password authentication.
- Google Sign-In bridged into Supabase Auth.
- Firebase initialization, Crashlytics and App Check.
- Analytics abstraction with Firebase implementation and mocks.
- Notification manager/delegate and deep-link handling.
- Security/biometric service.
- Mock data and repository abstractions.
- Supabase network configuration.

### Web

The existing frontend is a Next.js/TypeScript application deployed to Vercel and already contains a public landing page with reusable Header, Hero, Card and Footer components.

The current public messaging should be retained as a starting point but repositioned toward **financial protection/control**, not merely a generic family wallet.

### Backend

The existing Supabase project is active in `sa-east-1` and already contains:

- `profiles`
- `beneficiary_accounts`
- `transactions`
- `risk_alerts`
- `lessons`
- `user_progress`
- `achievements`
- `savings_goals`
- `transfer_destinations`

Existing RLS policies already encode important benefactor/beneficiary relationships.

## 6. MVP domain model

The current schema is sufficient to start the MVP. Avoid introducing a large new schema until the core loop exposes a concrete gap.

Core entities:

```text
profiles
  ↓
beneficiary_accounts
  ↓
transactions
  ↓
risk_alerts
```

`risk_alerts` is the central approval workflow entity for MVP.

## 7. Product rules

1. MVP does not move real money.
2. Benefactor is the primary user.
3. A beneficiary account is a supervised financial context, not a second MVP product.
4. Risk/approval is more important than payment breadth.
5. Existing iOS architecture is extended, not replaced.
6. Existing Supabase tables are reused where they fit.
7. Firebase Analytics is the initial analytics implementation on iOS.
8. The web frontend is the acquisition/validation surface first; it is not a second complete wallet.
9. Android starts only after the iOS core loop has been validated.
10. KYC and fintech integrations are post-validation work.

## 8. Success criteria for MVP beta

The MVP is ready for a closed beta when a benefactor can:

1. Sign in.
2. See or create a beneficiary account.
3. Configure at least one protection rule.
4. Trigger a simulated transaction.
5. See the transaction evaluated against the rule.
6. Receive a risk alert.
7. Open the alert from a notification/deep link.
8. Approve or reject it.
9. See the resulting state reflected in the transaction/alert history.
10. Generate analytics events for the complete loop.

## 9. Product metrics

### Acquisition

- `landing_viewed`
- `waitlist_started`
- `waitlist_completed`

### Activation

- `registration`
- `login`
- `beneficiary_created`
- `rule_created`

### Core value loop

- `transaction_created`
- `transaction_completed`
- `transaction_blocked`
- `risk_alert_created`
- `risk_alert_viewed`
- `transaction_approved`
- `transaction_rejected`
- `risk_alert_resolved`

### Quality/value

- Approval resolution rate.
- Median time from alert creation to decision.
- Percentage of activated benefactors who create a rule.
- Percentage of activated benefactors who encounter and resolve an alert.
- D7/D30 retention during beta.

## 10. Analytics principle

Analytics must answer product questions, not merely record screens. Existing `AnalyticsManager` is retained and expanded around the core loop.

Sensitive financial values should not be used as user-identifying analytics dimensions. Prefer event type, category, status and coarse/non-sensitive attributes.

## 11. Non-functional MVP requirements

- RLS must enforce benefactor/beneficiary access boundaries.
- No service-role secrets in clients.
- Crash reporting enabled.
- Analytics enabled with a mock implementation for tests.
- Push notification/deep-link flow must be deterministic.
- Core approval state transitions must be idempotent.
- Test data must be clearly distinguishable from real financial data.

## 12. Definition of Done

A feature is MVP-complete when:

- the happy path works against Supabase;
- authorization/RLS is verified;
- loading, empty and error states exist;
- analytics are instrumented;
- relevant unit tests exist;
- no real-money assumption is introduced;
- the feature can be exercised in a repeatable test scenario.

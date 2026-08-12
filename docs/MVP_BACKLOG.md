# Monederito — MVP Technical Backlog

**Priority:** P0 = beta blocker/core, P1 = next iteration, P2 = deferred

## EPIC 0 — Product foundation

### P0-001 — Establish MVP domain contracts
**Goal:** Align iOS models, Supabase schema and product terminology.

Tasks:
- Document states for `transaction` and `risk_alert`.
- Define allowed state transitions.
- Confirm `profiles.role` semantics.
- Confirm beneficiary ownership through `beneficiary_accounts.benefactor_id`.
- Generate/update Swift models from the actual schema where useful.

### P0-002 — Define analytics taxonomy
Tasks:
- Keep existing analytics abstraction.
- Add core-loop events.
- Standardize event names and parameters.
- Add mock analytics assertions in tests.

## EPIC 1 — Authentication & identity

### P0-101 — Verify Supabase Auth flows
- Email/password sign in.
- Registration.
- Google sign in.
- Session restoration.
- Sign out.
- Password reset.
- Profile creation/trigger behavior.

### P0-102 — Verify authorization boundaries
- Benefactor can only access own profile/beneficiary data.
- Beneficiary can only access own supervised account/allowed data.
- Test every relevant RLS policy.

### P0-103 — Harden Supabase Auth/backend security
- Fix `handle_new_user` mutable search path.
- Restrict public execution of `handle_new_user` if not intentionally exposed.
- Enable leaked-password protection.
- Re-run security advisor.

## EPIC 2 — Beneficiary account

### P0-201 — Benefactor beneficiary list
- Fetch supervised beneficiaries.
- Empty state.
- Loading/error states.
- Select beneficiary.

### P0-202 — Create beneficiary account
- Benefactor creates beneficiary profile/account representation.
- Set nickname.
- Set daily limit.
- Set monthly limit.
- Set allowed categories.
- Set blocked categories.

### P0-203 — Edit protection settings
- Update limits/categories.
- Validate numeric values.
- Confirm changes are persisted.
- Track `rule_created` / `rule_updated` analytics.

## EPIC 3 — Transaction simulation / domain core

### P0-301 — Create test transaction
- Create transaction with amount/category/merchant.
- Clearly mark/test scenario in development environment.
- Do not connect to real payment rails.

### P0-302 — Rule evaluation
Implement deterministic MVP rules in this order:
1. blocked category → blocked
2. amount above applicable limit → approval/risk
3. allowed category + within limits → completed
4. otherwise → configurable default behavior

Keep evaluation logic testable outside the UI.

### P0-303 — Transaction state machine
Suggested states:
- `pending`
- `completed`
- `blocked`
- `requires_approval`
- `rejected`

Define legal transitions and prevent duplicate decisions.

## EPIC 4 — Risk alerts / approval

### P0-401 — Create risk alert
- Associate alert with transaction.
- Associate beneficiary and benefactor.
- Persist amount, merchant, category, status and educational tip.
- Define alert status transitions.

### P0-402 — Benefactor alerts list
- Pending/resolved sections or equivalent.
- Unread state.
- Empty state.
- Error state.

### P0-403 — Alert detail
Display:
- beneficiary
- merchant
- amount
- category
- why the rule triggered
- current status
- action buttons

### P0-404 — Approve / reject
- Approve transaction.
- Reject transaction.
- Resolve alert.
- Make actions idempotent.
- Track analytics.

### P0-405 — Notification/deep-link integration
Reuse existing notification/deep-link infrastructure.

Flow:
`risk_alert_created → push → tap → monederito://alert/{alertID} → alert detail`

## EPIC 5 — Dashboard

### P0-501 — Benefactor dashboard
Minimum content:
- selected beneficiary/account
- current/remaining monthly amount
- recent transactions
- pending risk alerts
- simple risk/activity summary

Do not build advanced reporting yet.

### P1-502 — Spending visualization
- Category breakdown.
- Basic period comparison.
- Avoid unnecessary chart complexity.

## EPIC 6 — Analytics

### P0-601 — Acquisition analytics (web)
- landing_viewed
- CTA_clicked
- waitlist_started
- waitlist_completed

### P0-602 — Activation analytics (iOS)
- registration
- login
- beneficiary_created
- rule_created

### P0-603 — Core-loop analytics
- transaction_created
- transaction_completed
- transaction_blocked
- risk_alert_created
- risk_alert_viewed
- transaction_approved
- transaction_rejected
- risk_alert_resolved

### P0-604 — Product measurement
Create a simple dashboard/report for:
- activation rate
- rule creation rate
- alert resolution rate
- median alert decision time
- D7/D30 retention

## EPIC 7 — Web acquisition

### P0-701 — Reposition existing landing
Keep existing visual system/components, but update copy toward protection/control.

Proposed positioning:
> Protegé las finanzas de tu familia sin tener que revisar cada gasto.

### P0-702 — Lead capture
- Waitlist form.
- Store consent appropriately.
- Capture only useful qualification fields.
- Track conversion.

Suggested fields:
- email
- relationship to beneficiary
- primary concern

### P0-703 — Beta CTA
- Clear beta/waitlist CTA.
- Avoid promising real-money capabilities that do not exist.

## EPIC 8 — Testing & beta readiness

### P0-801 — Unit tests for rule evaluation
Cover:
- blocked category
- over monthly limit
- over daily limit
- allowed transaction
- conflicting categories/rules
- repeated decision

### P0-802 — Repository/integration tests
- Auth.
- Beneficiary access.
- Transaction creation.
- Alert creation.
- Approval/rejection.

### P0-803 — End-to-end happy path
Test:
`login → beneficiary → rule → transaction → alert → notification/deep link → approve/reject`

### P0-804 — Beta data reset/seed strategy
Create repeatable test data for development and TestFlight beta.

## EPIC 9 — P1 education

### P1-901 — Contextual educational feedback
Use `risk_alerts.educational_tip` first. Do not build a large learning product yet.

### P1-902 — Lessons/progress
Only after core protection loop has evidence of use. Existing tables can be reused.

## EPIC 10 — P2 / deferred platform and fintech work

### P2-1001 — Real payments
### P2-1002 — Bank/PSP integration
### P2-1003 — Real KYC
### P2-1004 — Card/QR/transfers
### P2-1005 — Android

These are explicitly not blockers for MVP validation.

---

# Recommended execution order

```text
1. Security + domain contracts
2. Auth/RLS verification
3. Beneficiary account CRUD
4. Rule evaluation
5. Transaction simulation
6. Risk alert state machine
7. Approve/reject
8. Notifications/deep links
9. Dashboard
10. Analytics instrumentation
11. Landing + lead capture
12. E2E tests
13. TestFlight beta
```

## MVP exit criteria

The backlog is MVP-complete when one benefactor can repeatedly execute the complete core loop with Supabase-backed data, receive a notification, make a decision, observe the resulting state, and have the complete journey measured in analytics.

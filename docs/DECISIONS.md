# Monederito — Decision Log

This file is the durable record of product and technical decisions that affect the MVP. New decisions should be appended with a date and rationale. Existing decisions should not be silently rewritten; superseding decisions should reference the previous decision.

## DEC-001 — MVP validates the control layer, not a new wallet
**Date:** 2026-08-12  
**Status:** Accepted

Monederito's first MVP will validate financial protection/delegation for a benefactor supervising a beneficiary. It will not attempt to become a full payment wallet.

**Rationale:** The research identifies control, visibility, alerts and selective approval as the differentiated value. Payment infrastructure would dramatically expand technical, regulatory and operational scope before product-market validation.

---

## DEC-002 — Benefactor is the primary MVP user
**Date:** 2026-08-12  
**Status:** Accepted

The MVP optimizes the benefactor experience. Beneficiary functionality exists only where necessary to represent the supervised account and generate/use the core transaction flow.

**Rationale:** The research and current product direction place the benefactor's need for delegated control at the center of the value proposition.

---

## DEC-003 — Approval/risk resolution is the core product loop
**Date:** 2026-08-12  
**Status:** Accepted

The primary loop is: configure protection → transaction occurs → rule evaluation → alert/approval → benefactor decision → resolved state.

**Rationale:** This is the smallest loop that demonstrates Monederito's differentiated value.

---

## DEC-004 — MVP does not move real money
**Date:** 2026-08-12  
**Status:** Accepted

Transactions in MVP are simulated/sandboxed. No bank, PSP, card, QR or real transfer integration is required for the first beta.

**Rationale:** Allows validation of the product behavior before taking on fintech infrastructure, compliance and operational risk.

---

## DEC-005 — Preserve the existing iOS architecture
**Date:** 2026-08-12  
**Status:** Accepted

The current SwiftUI architecture, dependency injection, repositories, Supabase Auth, Firebase Analytics/Crashlytics/App Check, notification/deep-link handling, security services and mock data are foundations to extend rather than rewrite.

**Rationale:** The repository already contains meaningful infrastructure aligned with the MVP and rewriting it would create technical churn without increasing product learning.

---

## DEC-006 — Reuse the existing Supabase domain model first
**Date:** 2026-08-12  
**Status:** Accepted

The existing `profiles`, `beneficiary_accounts`, `transactions` and `risk_alerts` tables form the initial core domain. `lessons`, `user_progress`, `achievements`, `savings_goals` and `transfer_destinations` remain available as P1/P2 capabilities.

**Rationale:** The existing schema already models the primary entities and RLS relationships required for the MVP.

---

## DEC-007 — Firebase Analytics is the initial product analytics layer on iOS
**Date:** 2026-08-12  
**Status:** Accepted

The existing analytics abstraction and Firebase implementation remain the initial analytics path. Product events will be expanded around activation and the risk/approval loop.

**Rationale:** Analytics infrastructure is already implemented in the iOS repository; replacing it would add cost without improving validation.

---

## DEC-008 — Web is acquisition and validation first
**Date:** 2026-08-12  
**Status:** Accepted

The Next.js frontend will prioritize landing, positioning, waitlist/lead capture and eventually lightweight product/admin surfaces. It will not become a complete web wallet during MVP validation.

**Rationale:** The existing frontend is small and already structured as a public landing page. Its highest leverage is validating demand and acquiring beta users.

---

## DEC-009 — iOS before Android
**Date:** 2026-08-12  
**Status:** Accepted

Continue native iOS development first. Android starts after the core loop has been validated with beta users and the domain/API contracts have stabilized.

**Rationale:** iOS already has the most mature implementation and allows faster iteration with the current codebase.

---

## DEC-010 — Avoid premature fintech/KYC scope
**Date:** 2026-08-12  
**Status:** Accepted

Production KYC, DNI/facial verification, cards, bank integrations, real transfers, fraud/AML and real-money custody are post-validation concerns.

**Rationale:** These capabilities are infrastructure/regulatory work, not necessary to validate the MVP product hypothesis.

---

## DEC-011 — Security findings are backlog items before beta
**Date:** 2026-08-12  
**Status:** Accepted

Supabase security advisor findings must be addressed before exposing the backend to a meaningful external beta. Current findings include mutable function search path, publicly executable `SECURITY DEFINER` `handle_new_user`, and disabled leaked-password protection.

**Rationale:** The MVP already has RLS and authentication foundations, but the current advisor findings indicate hardening work is still required.

---

## DEC-012 — Do not expand the schema without a product need
**Date:** 2026-08-12  
**Status:** Accepted

Prefer adapting the existing schema over introducing additional tables. Add new entities only when a concrete MVP use case cannot be represented safely and cleanly by the current model.

**Rationale:** Keeps the backend comprehensible for a solo developer and reduces migration/security surface area.

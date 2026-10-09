# Monederito workflow

Monederito is a SwiftUI sandbox wallet for portfolio. The current product scope is docs/WALLET_PLAN.md. Do not restore fraud blocking or parental approval as the core loop. Keep MVVM, repositories and DI; finish flows before redesign.

For a user-requested backlog ticket:
- Read the ticket and acceptance criteria; inspect current origin/develop and applicable instructions.
- Use one short branch and one PR to develop for the ticket. Preserve existing local changes.
- Use Monederito-Mock for verification without service credentials. Keep Package.resolved unchanged unless the ticket explicitly needs a dependency update.
- Run git diff --check and relevant iOS build/tests using Scripts/ci-ios.sh. Inspect failures and fix the same PR. Report genuine environment limitations.
- Document concrete changes, test results, remaining limitations and the user's local walkthrough in the PR.
- Wait for explicit user approval before merging. Do not start a dependent ticket before its prerequisite is integrated.
- Keep the app sandbox; external credit sources such as Pasito are future work.

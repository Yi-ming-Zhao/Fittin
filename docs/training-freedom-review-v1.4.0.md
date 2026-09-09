# v1.4.0 implementation review

## Data correctness

- Schedule preview tokens are checked before mutation; instance versions and active drafts are checked again within the transaction.
- Skip creates no workout log and does not apply performance-based weight progression.
- Free sessions use a separate owner-scoped draft and stable conclusion identity, with no plan engine conclusion.
- History recording uses an isolated notifier, preserves trusted IDs, dates, units, RPE and snapshots, and cannot overwrite the active draft.
- Delete-only preserves progression. Release restores an exact matching latest snapshot, or queues a recovery occurrence while retaining newer history. Restored occurrences receive a new generation so deleted log IDs cannot be reused.
- Native Isar and Web IndexedDB fault injection verifies rollback of instance, history and sync queue together; repeated release is refused.
- History replay refreshes its post-snapshot, refuses to affect a live draft, and declines progression replay after changing exercise identities.

## Catalog and presentation

- 222 stable bilingual catalog entries, including retained selection slots, validated primary/secondary muscles, aliases and structured execution fields. This is broad curated coverage, not a claim to enumerate every possible variation.
- Agent proposals include execution fields in previews and retain all confirmation, CAS, owner and undo checks. Repository hydration validates the same fields.
- Eight semantic palettes drive the three anatomy views and dumbbell illustration. Anatomy explicitly depicts completed-set exposure rather than diagnosis or recovery.
- Real Flutter Web synthetic-data flow verified free training selection, weight change, three-set recording, conclusion and analytics inclusion.
- Responsive widgets cover short/long phones, 320px, Chinese/English, 1.6x text, keyboard and desktop; screen inventory includes the new free-training route.
- Inspected 28 synthetic Web scenarios, including all eight anatomy palettes and nested editors. Fixed full-width filter chips found during visual review; regression checks compact wrapping and 44px touch targets. QA text now uses the production typography configuration.

## Build evidence and release gate

- PR #13 CI run `34327891248` passed Flutter tests/analyze, Go, Linux, Windows, macOS and unsigned iOS builds at `6173a5648eb731f748543f3b56de1e5973f757a4`.
- Local Chrome transaction/migration suite: 19 passed. Local training-freedom tests: 10 passed. History-recording UI, eight-palette dumbbell, side-view anatomy, catalog execution and Agent library tests passed.
- OpenSpec strict validation: 76 passed, 0 failed.
- Production artifacts, public deployment and Android in-place upgrade passed their separate gates; see [release verification](release-verification-v1.4.0.md), including the observed local-proxy cold-start limitation and unsigned platform boundaries.
- iOS public installation requires distribution signing; unsigned `.app` bundles must be labeled clearly. Desktop bundles are not Apple-notarized or commercially Windows-signed.

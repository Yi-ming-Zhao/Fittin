## 1. Domain contracts and persistence

- [x] 1.1 Add validated domain models for microcycle ordering, custom exercise entries, typed cardio definitions/records, import previews, and custom palettes.
- [x] 1.2 Add the generic versioned user-content Isar collection and include it in native bootstrap and migration tests.
- [x] 1.3 Upgrade Web IndexedDB additively to v4 with a `user_content` store and migration/blocked-upgrade coverage.
- [x] 1.4 Add owner-scoped user-content repository CRUD, soft deletion, compare-and-set versions, local claim, and queue integration for native and Web.
- [x] 1.5 Add backend user-content schema/endpoints and extend native/Web sync with conflict-safe hydration.

## 2. Flexible strength training

- [x] 2.1 Implement deterministic microcycle schedule resolution, reorder validation, versioned persistence, cycle reset, and plan-engine tests.
- [x] 2.2 Add a Home training-day chooser that blocks active drafts and keeps Home/session schedule identity in sync.
- [x] 2.3 Build a tagged searchable exercise catalog that merges immutable bundled and owner-scoped custom entries.
- [x] 2.4 Add in-session exercise replacement with compatibility metadata, completed-set protection, draft persistence, and correct performed-movement logs.
- [x] 2.5 Add exercise catalog management UI and localized validation/search/filter states.

## 3. Cardio tracking and import

- [x] 3.1 Seed the typed cardio activity library and implement per-type record validation plus canonical unit derivation.
- [x] 3.2 Build the Home cardio activity chooser and adaptive record editor for built-in/custom activities.
- [x] 3.3 Implement local GPX, TCX, FIT, and CSV parsing into warning-bearing import previews with source fingerprints.
- [x] 3.4 Add import file selection, CSV mapping, duplicate detection, confirmation, and record persistence UI.
- [x] 3.5 Add cardio history/detail/edit/delete surfaces and refresh affected analytics after local-first writes.

## 4. Analytics, appearance, and profile structure

- [x] 4.1 Extend progress providers with explicit strength/cardio ranges and modality-appropriate summaries.
- [x] 4.2 Add theme-derived strength/cardio encodings, legends, non-color markers, filters, and accessibility semantics to trends.
- [x] 4.3 Add additional restrained built-in palettes and contrast/hue/separation guard tests.
- [x] 4.4 Implement custom palette persistence, deterministic semantic-role derivation, live preview, editing, deletion fallback, and launch restoration.
- [x] 4.5 Replace the mixed profile root with category rows and coherent Account, Appearance, Training, Data & Privacy, Agent, and About subpages.

## 5. Agent and authentication

- [x] 5.1 Add bounded Agent read tools for exercise and palette libraries.
- [x] 5.2 Add complete-diff Agent proposals for custom exercise and custom palette create/revise/delete with built-in protection, confirmation, conflict checks, audit, and undo.
- [x] 5.3 Add rotating backend refresh sessions, legacy-session bootstrap, revocation, rate/size guards, and Go tests.
- [x] 5.4 Persist refresh credentials securely, refresh before expiry and once after authenticated 401, and retain cached identity on offline/transient startup errors.
- [x] 5.5 Add authentication restart, expiry, revocation, malformed gateway, and explicit-sign-out regression tests.

## 6. Whole-app layout audit

- [x] 6.1 Consolidate safe-area ownership and shared phone gutters/vertical rhythm in page, dialog, and sheet primitives.
- [x] 6.2 Inventory every navigable route and refactor main screens plus deep subpages to the shared spacing and scrolling rules.
- [x] 6.3 Add route-complete 320×568, 390×568, 390×844, 390×926, large-text, keyboard, and desktop overflow/touch-target tests.
- [x] 6.4 Run local Web visual inspection across all themes and both languages, fixing remaining density, clipping, scroll, and console issues.

## 7. Verification and release

- [x] 7.1 Regenerate source artifacts, format changed Dart/Go, run focused tests after each area, then run analyze and full Flutter/Go/OpenSpec validation once.
- [ ] 7.2 Build Android, iOS `--no-codesign`, and Web; verify a signed in-place Android upgrade from v1.2.1 preserves data, appearance, Agent state, and login.
- [ ] 7.3 Complete OpenSpec implementation verification, synchronize delta specs, and record release notes plus reproducible verification evidence.
- [ ] 7.4 Merge through a green PR, synchronize 241, deploy the compatible backend and Web with rollback points, publish tag/GitHub assets, and advance first-party `latest.json` last.
- [ ] 7.5 Verify public ready/auth refresh/Web/cardio smoke paths, signed APK/AAB identity and hashes, GitHub assets, and Android update detection for `v1.3.0+26`.

## 1. Unified Theme Foundation

- [x] 1.1 Implement the five-palette registry and complete semantic `FittinTheme` color roles.
- [x] 1.2 Make the selected palette the single source for Fittin widgets and Material `ThemeData`.
- [x] 1.3 Persist the palette with synchronous startup restoration and safe fallback for unknown values.
- [x] 1.4 Centralize fixed Olympic equipment and export artwork colors as named domain palettes.
- [x] 1.5 Add a maintained color-role inventory that maps every themeable app area to semantic tokens and documents intentional exceptions.

## 2. Appearance Settings

- [x] 2.1 Add complete English and Chinese strings for Appearance, palette names, descriptions, and accessibility labels.
- [x] 2.2 Build the inline My/Settings Appearance section with representative preview tiles and immediate selection feedback.
- [x] 2.3 Ensure every palette preview is reachable, touch-friendly, and semantically selected on a narrow phone.

## 3. Semantic Color Migration

- [x] 3.1 Migrate shared dashboard, card, navigation, form, dialog, overlay, and control primitives from literal UI colors to semantic roles.
- [x] 3.2 Migrate interactive charts, compact charts, heat maps, and anatomy rendering to palette data roles.
- [x] 3.3 Migrate workout state, gesture feedback, history, and high-risk screen backgrounds to semantic roles while preserving domain-fixed equipment colors.
- [x] 3.4 Add automated guards for palette completeness, contrast, no cyan/teal, and Material/Fittin synchronization.

## 4. Adaptive Today And Body Layouts

- [x] 4.1 Implement bounded relaxed and compact Today compositions based on safe content height.
- [x] 4.2 Implement the Body 2+1 narrow metric composition and three-column wide composition.
- [x] 4.3 Make Body chart height, section rhythm, loading, empty, partial, and populated states adapt without center clustering or overflow.

## 5. Automated Verification

- [x] 5.1 Add provider tests for instant palette updates, persistence, restart restoration, and unknown-value fallback.
- [x] 5.2 Add Settings widget tests for bilingual appearance content, preview reachability, and live selection.
- [x] 5.3 Add real app-shell geometry tests at 390x926 and 390x568 for Today and Body, including bottom navigation clearance.
- [x] 5.4 Update chart, anatomy, active-session, and existing theme regression tests for semantic palettes.
- [x] 5.5 Run formatting, static analysis, the full Flutter test suite, backend tests, and strict OpenSpec validation.

## 6. Visual QA And Specification Sync

- [x] 6.1 Build the production web app and inspect Today, Body, Appearance, workout, charts, and navigation for every palette at 390x926.
- [x] 6.2 Repeat the palette matrix at 390x568 in English and Chinese, iterating until there is no overflow, clipping, unreadable contrast, or awkward distribution.
- [x] 6.3 Synchronize the delta specifications into main specs and record final verification evidence.

## 7. Release And Deployment

- [x] 7.1 Bump the app to `1.0.9+16` and generate release notes that document themes and adaptive layouts.
- [x] 7.2 Commit and push the scoped implementation, then wait for Flutter and backend CI to pass.
- [x] 7.3 Publish tag `v1.0.9` with signed APK/AAB assets and verify checksums, version metadata, and the stable Android signer.
- [ ] 7.4 Synchronize the 241 repository, deploy the web build directly to Alibaba Cloud, and verify public assets, API health, nginx headers, and rollback metadata.

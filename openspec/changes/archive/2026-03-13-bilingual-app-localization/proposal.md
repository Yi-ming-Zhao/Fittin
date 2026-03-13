## Why

The app currently behaves as an English-only product even though the primary user flow, built-in plans, and product discussion now happen in Chinese as well. Adding a real language setting is necessary so the UI and built-in training plans can present Chinese and English consistently instead of mixing hard-coded English strings with Chinese-only user expectations.

## What Changes

- Add a settings entry under the bottom-nav profile/personal area so users can choose the app language.
- Add Chinese as a supported language alongside English for app chrome, dashboard, plan library, active session, sharing, and settings surfaces.
- Localize built-in training plan metadata and exercise labels so GZCLP and Jacked & Tan can be previewed, activated, and performed in Chinese.
- Update plan presentation flows so the currently selected language is reflected when listing plans and rendering workout/session text.

## Capabilities

### New Capabilities
- `app-language-settings`: language preference storage, settings UI, and runtime locale switching for the app shell.
- `localized-plan-content`: bilingual built-in plan names, descriptions, workout titles, and exercise labels.

### Modified Capabilities
- `plan-library-switching`: plan previews and activation flows must render localized plan text according to the selected language.

## Impact

- Affected code includes the app shell/profile tab, settings UI, app-level state/providers, presentation widgets/screens, and built-in plan seed assets.
- Built-in JSON templates will need bilingual text fields or localization keys so plan sharing and previewing remain consistent.
- Tests will need to cover language switching, localized plan previews, and Chinese rendering for built-in program content.

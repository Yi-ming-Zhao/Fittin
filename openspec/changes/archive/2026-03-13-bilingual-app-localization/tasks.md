## 1. Locale State and Settings Surface

- [x] 1.1 Add a persisted app-language preference model/provider and wire it into app startup.
- [x] 1.2 Replace the personal/profile placeholder tab with a settings surface and add a language settings entry.
- [x] 1.3 Build the language selection UI with English and Chinese options and immediate runtime switching.

## 2. App String Localization

- [x] 2.1 Introduce localized app-owned strings for navigation, dashboard, plan library, active session, sharing, and settings text.
- [x] 2.2 Update presentation widgets and screens to resolve app strings from the selected locale instead of hard-coded English copy.

## 3. Built-in Plan Localization

- [x] 3.1 Extend plan/template models and text-resolution helpers to support bilingual built-in plan content with plain-text fallback.
- [x] 3.2 Update the built-in GZCLP and Jacked & Tan seed assets to include Chinese and English plan/workout/exercise display text.
- [x] 3.3 Update plan library, today workout summary, and active session rendering to use locale-aware plan text.

## 4. Verification

- [x] 4.1 Add unit tests for locale preference persistence and localized plan text resolution.
- [x] 4.2 Add widget tests for the settings language switcher, Chinese plan previews, and localized dashboard/session text.
- [x] 4.3 Run the relevant automated tests and verify bilingual built-in plans still serialize and remain shareable.

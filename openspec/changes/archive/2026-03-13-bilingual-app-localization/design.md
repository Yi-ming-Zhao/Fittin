## Context

The app already has a bottom navigation shell, a placeholder personal/profile tab, and JSON-first built-in plan assets. All visible UI copy and seeded plan text are effectively English-only today, which creates two coupled problems: there is no runtime locale selection, and built-in plans cannot present Chinese names/descriptions/exercise labels even if the UI shell is translated.

This change crosses multiple layers:
- app-level settings and persisted preference state
- the profile/personal tab and a new settings destination
- presentation strings across dashboard, plan library, active session, and sharing
- built-in plan asset structure and rendering helpers so plan text can switch languages without duplicating program logic

The implementation should preserve existing local-first behavior, QR/template sharing, and plan switching while making language selection an explicit app setting.

## Goals / Non-Goals

**Goals:**
- Add a settings surface under the personal/profile tab that lets users switch between English and Chinese.
- Persist the selected language locally and apply it immediately across the app shell.
- Localize built-in plan names, descriptions, workout titles, day labels, and exercise labels for GZCLP and Jacked & Tan.
- Ensure plan previews, workout summaries, and active session screens resolve text using the selected language.

**Non-Goals:**
- Add remote translation delivery, cloud profile sync, or account-based preference storage.
- Fully internationalize custom user-authored plan content in this change; user-authored text remains as entered.
- Introduce a large external localization platform or server dependency.

## Decisions

### 1. Introduce a lightweight app-locale state with local persistence
Add an app-level locale preference provider backed by local storage so the selected language survives app restarts. The setting should default to the current English behavior when no preference exists, but Chinese must be selectable from settings and applied immediately without restarting.

Rationale:
- keeps localization state explicit and testable
- avoids coupling language choice to OS locale in the first implementation
- matches the existing local-first architecture

Alternative considered:
- infer locale only from system language. Rejected because the user explicitly wants a settings control and because plan screenshots/sharing may be performed in a different language than the device default.

### 2. Keep plan logic JSON-first and add bilingual display content instead of duplicating templates
Built-in templates should retain one logical program definition, but text-bearing fields should be extended to support localized display content. The data model can either use localized string maps or structured bilingual labels, but the rendering layer must resolve one display value based on the selected app language.

Rationale:
- preserves one source of truth for each built-in program
- keeps QR export/share compatible with the current JSON-based transport
- avoids creating separate English/Chinese versions of the same plan

Alternative considered:
- ship separate `*-zh` templates. Rejected because it duplicates program IDs, complicates switching/share flows, and risks divergence between translations.

### 3. Add a real settings screen under the personal tab instead of embedding language controls in plan screens
The profile/personal tab should stop being a placeholder and instead expose a settings entry point. Language selection belongs there rather than in the plan library because it affects the whole app, not only plan browsing.

Rationale:
- aligns the setting with user expectations
- avoids scattering global preferences across feature screens
- gives the currently empty personal tab a concrete product role

Alternative considered:
- add a language button directly on the dashboard or plan library. Rejected because it is a global app preference and would clutter task-oriented screens.

### 4. Resolve localized text in presentation helpers instead of forcing every widget to understand raw localization maps
Introduce a small localization helper layer so widgets ask for display strings rather than manually branching over localized JSON fields. This helper should cover built-in plan text resolution and app string lookup.

Rationale:
- reduces repeated locale branching in widgets
- keeps custom plan fallback behavior centralized
- makes tests easier because text resolution is deterministic

### 5. Scope built-in plan localization to seeded content and preserve user-authored text as-is
Built-in GZCLP and Jacked & Tan assets should be updated with bilingual metadata. User-authored and imported plans should continue displaying their stored text without forced machine translation.

Rationale:
- avoids inventing translations for user content
- keeps migration straightforward for existing custom templates
- satisfies the user requirement for built-in plans while keeping implementation realistic

## Risks / Trade-offs

- [Risk] Localizing built-in plan JSON increases asset size and QR payload size.  
  Mitigation: keep localization payload compact and continue using the existing compressed export format.

- [Risk] App strings and plan strings may drift if they use separate lookup patterns.  
  Mitigation: add a single locale preference source and shared resolution helpers for both app chrome and plan content.

- [Risk] Existing tests that assert hard-coded English strings may become brittle.  
  Mitigation: update tests to pin both default English behavior and explicit Chinese switching behavior.

- [Risk] Imported or edited custom plans may not have bilingual fields.  
  Mitigation: treat bilingual text as optional and fall back to the stored plain-text fields when localized content is absent.

## Migration Plan

1. Add persisted app-locale preference state and wire it into app startup.
2. Replace the personal tab placeholder with a settings/profile surface that can navigate to language settings.
3. Add localized app strings and update presentation widgets/screens to use them.
4. Extend built-in plan assets and plan text resolution helpers to support English and Chinese labels.
5. Verify that plan library previews, today workout summaries, and active sessions reflect the selected language.
6. Confirm QR export/import still works for bilingual built-in templates.

Rollback strategy:
- locale preference can fall back to English if localization state is unavailable
- built-in templates can still render plain-text fallback fields if localized payload parsing fails

## Open Questions

- Should future custom-plan editing expose separate Chinese and English text fields, or is built-in bilingual support sufficient for now?
- Should the app eventually offer an automatic “follow system language” mode in addition to explicit English/Chinese selection?

## Context

Fittin v2 is transforming from a basic functioning prototype to a fully-fledged, modern strength training application. The current frontend lacks a cohesive design language, relies heavily on default Material components without thoughtful customization, and can feel cluttered during actual workout sessions. A major frontend redesign is needed to introduce a premium, minimalist user experience. The new design will leverage curated color palettes, elegant typography, intuitive micro-animations, and a highly spacious layout to minimize cognitive load while retaining the core zero-typing capabilities developed earlier.

## Goals / Non-Goals

**Goals:**
*   **Curated Theme System**: Implement a dynamic theming engine supporting multiple high-quality, harmonious color palettes (e.g., Deep Ocean, Minimalist Dark, Sunset Warmth) that users can easily switch between.
*   **Minimalist Core Layouts**: Redesign primary screens (Dashboard, Active Session, Plan Management) with a strong emphasis on whitespace and clear visual hierarchy. Remove non-essential UI elements.
*   **Premium Micro-animations**: Introduce subtle, fluid animations for state transitions (e.g., ticking off a set, page routing, expanding details) using Flutter's animation primitives to create a "silky smooth" feel.
*   **Component Standardization**: Create a unified set of custom widgets (Cards, Buttons, Inputs) that strictly adhere to the new minimalist design language.

**Non-Goals:**
*   Adding new functional features (like social feeds or video playback). This change is purely focused on UI/UX redesign of existing capabilities.
*   Over-the-top, complex 3D animations or heavy graphic assets that bloat the app size or distract from the training itself.

## Decisions

**1. Theme Management System: Riverpod + Local Persistence**
*   **Rationale**: We will use Riverpod to expose a `ThemeNotifier` that holds the currently selected color scheme. This allows instantaneous, app-wide UI updates. We will persist the user's choice in the local database (Isar) or SharedPreferences so it survives app restarts. 
*   **Alternatives Considered**: Hardcoding a single premium dark theme. *Rejected* because giving users the agency to choose among curated harmonious themes significantly enhances the "premium" feel and app personalization.

**2. Animation Strategy: Implicit Animations & declarative helpers**
*   **Rationale**: For micro-animations (like a checkbox morphing into a success icon, or a card subtly elevating on tap), Flutter's built-in implicit animated widgets (`AnimatedContainer`, `AnimatedScale`, `AnimatedOpacity`) are highly performant and easy to maintain. We will keep animations brief (150ms-300ms) to ensure the app feels snappy, not slow.
*   **Alternatives Considered**: Rive or Lottie animations. *Rejected* as they are overkill for core UI micro-interactions and better suited for illustrative empty states.

**3. Layout Philosophy: "Whitespace as a Feature"**
*   **Rationale**: The UI must avoid cramming too much into one view. We will restructure screens like `ActiveSessionScreen` so that the active exercise is the absolute focal point. Non-imminent sets or subtle details will be pushed down the visual hierarchy (using lower opacity, smaller fonts, or moving them off-screen). 

**4. Typography Upgrade**
*   **Rationale**: We will adopt a modern, clean geometric sans-serif font (e.g., `Inter`, `Outfit`, or `Manrope` via Google Fonts) to instantly elevate the aesthetic over default system fonts. This contributes massively to the "premium" vibe with very little performance cost.

## Risks / Trade-offs

*   **[Risk] Custom theming introduces maintenance overhead** → Mitigation: Strictly define an `AppColors` and `AppStyles` utility class that acts as the single source of truth for all color tokens and text styles. Avoid hardcoding inline colors (e.g., `Colors.blue`) in individual widgets. All widgets must reference the current theme context.
*   **[Risk] "Minimalist" design might hide too many important actions** → Mitigation: Ensure core actions (like finishing a set, adjusting weight) remain highly visible, intuitive, and accessible via the existing gesture-based controls (Zero-Type UI). We will rely on progressive disclosure for secondary actions, but never at the cost of primary utility.

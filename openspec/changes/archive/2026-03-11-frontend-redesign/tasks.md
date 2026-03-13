## 1. Setup Theme System & Typography

- [x] 1.1 Add `google_fonts` package to `pubspec.yaml` for modern geometric sans-serif fonts.
- [x] 1.2 Create `lib/src/presentation/theme/app_colors.dart` defining curated color palettes (e.g., Deep Ocean, Minimalist Dark).
- [x] 1.3 Create `lib/src/presentation/theme/app_styles.dart` defining text styles (using `GoogleFonts.inter` or similar) with appropriate typography hierarchy.
- [x] 1.4 Implement a Riverpod `ThemeNotifier` to manage and persist the active theme state (dummy persistence or Isar if available).
- [x] 1.5 Update `main.dart`'s `MaterialApp` to consume the active theme from the `ThemeNotifier`.

## 2. Premium Micro-Animations Components

- [x] 2.1 Refactor `SetInputRow` to include an implicit scale animation (e.g., using `GestureDetector` or `Listener` to detect tap down/up and `AnimatedScale`).
- [x] 2.2 Refactor the checkbox interaction in `SetInputRow` to use a smooth implicit animation (e.g., `AnimatedSwitcher` or `AnimatedContainer`) for morphing into a success icon.
- [x] 2.3 Ensure any dynamic route transitions (like pushing `ActiveSessionScreen`) use smooth fading or sliding animations seamlessly.

## 3. Minimalist Layout: Active Session Refactor

- [x] 3.1 Update `ActiveSessionScreen`: Clean up AppBar headers, replacing standard backgrounds with transparent/subtle tones.
- [x] 3.2 Update `ActiveSessionScreen`: Increase list item spacing and scaffold margins for a "whitespace as a feature" aesthetic.
- [x] 3.3 Redesign `SetInputRow` visual containers: simplify borders, rely on subtle background color shifts instead.
- [x] 3.4 Rethink `FloatingTimerWidget`: Apply soft, deep drop shadows (`BoxShadow`) and fully rounded corners, matching the premium theme.

## 4. Minimalist Layout: Other Screens

- [x] 4.1 Update `DemoHomeScreen`: Center the primary buttons, add breathing room, apply `AppStyles` typography.
- [x] 4.2 Update `ShareScreen` and `QRScannerScreen` layouts to strictly use the new tokenized colors and spacings.
- [x] 4.3 Clean up any remaining hardcoded colors (e.g., `Colors.blueAccent`, standard `Grey`) across the entire `presentation` folder.

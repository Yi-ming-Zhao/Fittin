## ADDED Requirements

### Requirement: Per-Exercise RM Profile
The system MUST maintain a performance profile for every canonical or custom exercise, including best observed loads by completed-repetition count, the best observed single without claiming it was a maximal test, best estimated 1RM, date, source workout, formula, and confidence.

#### Scenario: Completed set improves an exercise best
- **WHEN** a user saves a valid completed set whose load or estimated 1RM exceeds the stored best for that exercise and repetition count
- **THEN** the exercise profile updates from that workout while preserving provenance and without merging records from a different exercise identity.

### Requirement: Conservative Estimate Priority
Starting-load estimation MUST prefer the user's own profile for the same exercise, then a canonical anchor-lift relationship, and finally an explicitly labeled low-confidence fallback. It MUST NOT replace an explicit plan weight or a user-confirmed value.

#### Scenario: New plan contains an untested assistance exercise
- **WHEN** the user starts a plan containing a canonical assistance exercise with no personal performance record but a valid main-lift anchor
- **THEN** the app suggests a rounded starting load from the user's anchor profile, the exercise ratio, the target reps, and a conservative confidence adjustment
- **AND** it shows the source and allows confirmation or editing before use.

### Requirement: Estimate Safety Bounds
Estimated 1RM calculations MUST exclude invalid, skipped, bodyweight-only, and very high-repetition sets outside the supported formula range, and low-confidence machine or cable estimates MUST be presented as suggestions rather than objective equivalents.

#### Scenario: High-repetition or machine data is encountered
- **WHEN** a set exceeds the supported estimation range or equipment resistance is not comparable across machines
- **THEN** the app keeps the actual RM record but does not promote the result as a high-confidence barbell 1RM.

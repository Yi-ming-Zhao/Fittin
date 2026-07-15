# Exercise Library And Load-Estimation Sources

This document records the evidence and product-safety policy behind Fittin's canonical exercise library. Catalog ratios are editable starting priors, not universal physiological laws or medical advice.

## Source and licensing policy

- Competition-lift identity follows the [International Powerlifting Federation technical rules](https://www.powerlifting.sport/rules/codes/info/technical-rules): Squat / 深蹲, Bench Press / 卧推, and Deadlift / 硬拉.
- English taxonomy fields may be manually cross-checked against [free-exercise-db](https://github.com/yuhonas/free-exercise-db), whose repository is released under the [Unlicense](https://github.com/yuhonas/free-exercise-db/blob/main/LICENSE.md). Fittin does not import its images or prose instructions; any future import must pin a commit and retain source/license metadata.
- [wger](https://wger.readthedocs.io/en/latest/) may be used only when individual source/license/author attribution is retained. Its seeded exercise data is CC-BY-SA and must not be silently mixed into product-owned data.
- Anatomical English terms may be checked against [Terminologia Anatomica 2](https://libraries.dal.ca/Fipat/ta2.html). Fittin owns and reviews its Simplified Chinese UI translations.
- Commercial or non-open exercise databases and image sets are reference-only and are not scraped or redistributed.
- Exercise nomenclature is not consistent across the field; aliases are reviewed rather than assumed. See the [NSCA resistance-training nomenclature review](https://pmc.ncbi.nlm.nih.gov/articles/PMC8608004/).

Every imported or manually curated entry must retain `sourceIds`, `sourceRevision`, `license`, and the Fittin catalog version.

## RM and e1RM boundaries

Evidence used:

- Direct 1RM testing is generally reliable when the protocol, exercise, and population are controlled: [systematic review](https://pmc.ncbi.nlm.nih.gov/articles/PMC7367986/).
- Repetitions possible at a given percentage of 1RM vary materially by person and exercise: [meta-regression of 269 studies](https://pmc.ncbi.nlm.nih.gov/articles/PMC10933212/).
- Lower-repetition tests generally predict 1RM better than high-repetition tests: [Reynolds et al.](https://pubmed.ncbi.nlm.nih.gov/16937972/).
- Common prediction equations were developed from limited samples and must not be generalized without uncertainty: [equation-comparison review](https://www.unm.edu/~rrobergs/478PredictionAccuracy.pdf).
- RIR/RPE is useful but imprecise, with better accuracy closer to failure and at lower/moderate repetitions: [Zourdos et al.](https://pubmed.ncbi.nlm.nih.gov/30747900/) and [RIR scoping review](https://pubmed.ncbi.nlm.nih.gov/34542869/).

Fittin stores these concepts separately:

- `observedRepBest[n]`: heaviest valid completed set of exactly `n` repetitions;
- `observedSingleBest` (the current model's `actualOneRepMax` compatibility field): heaviest completed single, without claiming it was a maximal test;
- `estimated1RM`: formula-derived with formula, source, date, repetitions, and confidence; any performed RPE remains on the authoritative workout log;
- `trainingMax`: conservative plan input, never presented as a tested 1RM.

Estimation policy:

- A completed single remains an observed single because the current log schema does not record whether it was a maximal test.
- Formula estimates from 2–5 repetitions receive medium confidence for comparable free-weight exercises.
- Formula estimates from 6–10 repetitions receive low confidence.
- More than 10 repetitions update observed rep bests but never update e1RM.
- Invalid/zero loads, skipped sets, and uncompleted sets never update e1RM.
- Cable stacks, selectorized machines, assisted/bodyweight movements, and unlike load semantics are not compared as portable kilogram 1RMs. Machine mechanics can materially change delivered resistance; see [selectorized-machine biomechanics](https://pubmed.ncbi.nlm.nih.gov/21975575/).

The conservative planning estimate converts capacity with the user's selected supported formula after effective repetitions (`reps + clamped RIR`), applies a confidence-based safety factor, and rounds down to the supported increment. Formula provenance remains attached to the recommendation.

## Assistance-lift prior policy

There is no defensible fixed ratio for every assistance movement. A catalog entry may define an e1RM prior only as `center`, `lower`, `upper`, `evidenceGrade`, and source IDs. Personal same-exercise records replace the global prior as soon as sufficient data exists.

Evidence grades:

- **A/B**: replicated direct evidence suitable for a reasonably bounded prior;
- **C**: small or population-specific direct comparison; wide range required;
- **D**: conservative engineering/coaching prior used only to avoid a blind first session;
- **Calibration only**: no cross-exercise numeric estimate.

Initial curated priors:

| Exercise | Anchor | Center | Range | Grade | Notes |
| --- | --- | ---: | ---: | --- | --- |
| High-bar squat | Squat | 0.90 | 0.80–0.98 | D | Wide conservative prior; [front/back squat comparison](https://www.frontiersin.org/journals/physiology/articles/10.3389/fphys.2025.1727141/full). |
| High-bar pin squat | Squat | 0.82 | 0.70–0.92 | D | ROM/height dependent. |
| Close-grip bench press | Bench Press | 0.93 | 0.85–0.98 | C | Grip and training history matter; [direct comparison](https://pmc.ncbi.nlm.nih.gov/articles/PMC5968970/). |
| Incline dumbbell press | Bench Press | 0.40 | 0.325–0.475 | C | Per-dumbbell/load semantics differ from a barbell bench; keep the range wide. |
| Feet-up/Larsen bench press | Bench Press | 0.88 | 0.75–0.97 | D | Conservative product prior. |
| Overhead press | Bench Press | 0.60 | 0.45–0.75 | D | Low-confidence free-weight estimate. |
| Paused deadlift | Deadlift | 0.88 | 0.75–0.97 | D | Conservative product prior. |
| Romanian deadlift | Deadlift | 0.60 | 0.40–0.75 | D | Never encourages maximal testing. |
| Block/rack pull | none | — | — | Calibration only | Range of motion may allow more than the main lift. |

Pattern priors are allowed only for clearly comparable free-weight semantics and remain low confidence:

- bilateral knee-dominant free weight → Squat, roughly 0.55–0.90 with an exercise-specific center;
- hip-hinge free weight → Deadlift, roughly 0.40–0.80;
- horizontal free-weight press → Bench Press, roughly 0.55–0.95;
- vertical free-weight press → Bench Press, roughly 0.45–0.70;
- machine/cable/bodyweight/assisted movements → calibration only.

## Starting-load algorithm

Priority:

1. same-exercise profile;
2. catalog ratio prior applied to the user's matching Big Three anchor profile;
3. calibration flow with no numeric cross-exercise claim.

For a valid prior:

```text
auxiliaryE1RM = anchorE1RM * ratioCenter
effectiveReps = targetReps + targetRIR
formulaLoad = inverseSelectedFormula(auxiliaryE1RM, effectiveReps)
startingLoad = roundDown(formulaLoad * safetyFactor, increment)
```

- High-confidence safety factor: `0.95`.
- Medium-confidence safety factor: `0.90`.
- Low-confidence safety factor: `0.85`.
- Unknown target effort defaults to RIR 3.
- Explicit plan weights and user edits always win.
- Low-confidence estimates remain editable suggestions and require the normal plan-start review before use.
- After the first valid same-exercise set, Fittin updates later recommendations from personal evidence.

Progression guidance remains individualized. The ACSM position stand supports modest load increases after the athlete exceeds the target repetitions, but does not justify rigid universal ratios: [ACSM progression guidance](https://www.sportgeneeskunde.com/files/bestanden/VSG/VSG6672.pdf).

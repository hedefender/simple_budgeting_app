# Phase 4 notes

Findings collected before Phase 4 (rule engine over the stored OCR text). Not a plan; the plan comes at the start of Phase 4.
Added 2026-10-21 at the owner's request.

## Findings from a real electricity bill (Protergia)

- The text contains the Latin micro sign `µ` (U+00B5) where the Greek letter `μ` (U+03BC) is expected. Unicode normalization
  is needed before matching keywords.
- The amount to pay is the one next to "ΣΥΝΟΛΙΚΟ ΠΟΣΟ ΠΛΗΡΩΜΗΣ" (67,05 €). The rules must NOT pick "Τελική Χρέωση Picasso"
  (54,99 €).
- That document contains the user's personal data. It must NOT be put in the repository as a sample. The testing dataset uses
  only anonymized or synthetic texts.

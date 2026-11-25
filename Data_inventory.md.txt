# Data Quality Review (Work Requests 09–11)

## 1. Missing Values Check (Work Request 09)
- `age_empty`: 0
- `job_empty`: 0
- `education_empty`: 0
- `outcome_empty`: 0
- **Empty vs. `unknown`:** There are zero SQL `NULL` or blank values in these key fields. However, text values like `unknown` appear (for example, `330` records in `job`). `unknown` is an explicitly recorded category—not a missing/blank cell—and must be preserved as its own group rather than deleted.

## 2. Value Validity Check (Work Request 10)
- `y`: Only `no` and `yes` (no spelling errors or unexpected values).
- `contact`: Only `cellular` and `telephone`.
- `month`: 10 valid month abbreviations (`apr`, `aug`, `dec`, `jul`, `jun`, `mar`, `may`, `nov`, `oct`, `sep`); `jan` and `feb` do not appear in the dataset.
- `day_of_week`: Only `fri`, `mon`, `thu`, `tue`, `wed`.
- `poutcome`: Only `failure`, `nonexistent`, `success`.
- `age` numeric check: Returned **0 exceptions** (all 41,188 values are clean whole numbers).

## 3. Business Meaning & Interpretation Rules (Work Request 11)
- **Why `pdays = 999` is misleading as days:** `999` is a placeholder code meaning the client was *never previously contacted*, not 999 actual days. Including `999` in averages would distort the math.
- **Why `duration` is unavailable before a call:** Call length is only known *after* a conversation ends, so it cannot be used to choose which prospects to dial in a future campaign.
- **Why rows ≠ unique customers:** The dataset has no `customer_id`, so each row represents a *contact record* rather than a guaranteed unique person.
- **Why not delete duplicate-looking rows:** Without a unique customer identifier, two different clients sharing the same demographics and call day can look identical; deleting them risks removing valid records.

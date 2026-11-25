/* ============================================================================
   PROJECT: Bank Term Deposit Marketing Campaign Analysis
   ROLE:    Junior Data Analyst
   PURPOSE: Complete chronological log of setup, data loading, exploration, 
            and data quality checks (Work Requests 05 to 10).
   ============================================================================ */


-- ============================================================================
-- WORK REQUEST 05: PREPARE A SAFE LANDING AREA
-- Why: Create a locked 'raw' folder (schema) and a table where all 21 columns 
--      are stored as 'text' so the CSV loads safely without data-type errors.
-- ============================================================================

-- Step 5A: Create the 'raw' folder (schema) inside our database
CREATE SCHEMA IF NOT EXISTS raw;

-- Step 5B: Create the 21-column table matching the exact CSV column names
-- Note: Double quotes are used around "default" (a SQL keyword) and columns with dots
CREATE TABLE IF NOT EXISTS raw.bank_marketing (
    age text,
    job text,
    marital text,
    education text,
    "default" text,
    housing text,
    loan text,
    contact text,
    month text,
    day_of_week text,
    duration text,
    campaign text,
    pdays text,
    previous text,
    poutcome text,
    "emp.var.rate" text,
    "cons.price.idx" text,
    "cons.conf.idx" text,
    euribor3m text,
    "nr.employed" text,
    y text
);

-- Step 5C: Check PostgreSQL's master catalog to confirm all 21 columns exist as 'text'
SELECT ordinal_position, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'raw'
  AND table_name = 'bank_marketing'
ORDER BY ordinal_position;


-- ============================================================================
-- WORK REQUEST 06: VERIFY THE CSV IMPORT
-- Note: Data was imported via pgAdmin Import/Export tool (Delimiter: ';', Header: Yes)
-- ============================================================================

-- Step 6A: Count all rows to confirm all 41,188 records arrived safely
SELECT COUNT(*) AS records_received
FROM raw.bank_marketing;

-- Step 6B: Preview the first 10 rows to confirm columns lined up properly
SELECT *
FROM raw.bank_marketing
LIMIT 10;


-- ============================================================================
-- WORK REQUEST 07: TAKE AN INVENTORY OF THE DATASET
-- Why: Check the size, column structure, and sample values before doing math.
-- ============================================================================

-- Step 7A: Confirm total number of contact records
SELECT COUNT(*) AS total_records
FROM raw.bank_marketing;

-- Step 7B: List all 21 column names in their original order
SELECT ordinal_position, column_name
FROM information_schema.columns
WHERE table_schema = 'raw'
  AND table_name = 'bank_marketing'
ORDER BY ordinal_position;

-- Step 7C: Inspect 15 sample rows to identify categorical vs. numeric-looking fields
SELECT *
FROM raw.bank_marketing
LIMIT 15;


-- ============================================================================
-- WORK REQUEST 08: EXPLORE THE RECORDED VALUES
-- Why: Sort rows into piles (GROUP BY) and count them (COUNT) to see what values exist.
-- ============================================================================

-- Step 8A: Count how many records resulted in 'yes' (subscribed) vs. 'no'
SELECT y, COUNT(*) AS records
FROM raw.bank_marketing
GROUP BY y
ORDER BY y;

-- Step 8B: Count records by job category from largest group to smallest (DESC)
SELECT job, COUNT(*) AS records
FROM raw.bank_marketing
GROUP BY job
ORDER BY records DESC;

-- Step 8C: Count records by contact method (cellular vs. telephone)
SELECT contact, COUNT(*) AS records
FROM raw.bank_marketing
GROUP BY contact;

-- Step 8D: Count records by month (reveals 10 active months; Jan & Feb are missing)
SELECT month, COUNT(*) AS records
FROM raw.bank_marketing
GROUP BY month
ORDER BY month;

-- Step 8E: Check values in 'pdays' (reveals placeholder code 999 = never contacted before)
SELECT pdays, COUNT(*) AS records
FROM raw.bank_marketing
GROUP BY pdays
ORDER BY pdays;


-- ============================================================================
-- WORK REQUEST 09: CHECK FOR MISSING INFORMATION (NULL / BLANK vs. 'unknown')
-- Why: Make sure key fields are not empty, while preserving literal 'unknown' labels.
-- ============================================================================

-- Step 9A: Count any truly empty (NULL) or blank-space cells in key fields (Result: 0)
SELECT
  COUNT(*) FILTER (WHERE age IS NULL OR btrim(age) = '') AS age_empty,
  COUNT(*) FILTER (WHERE job IS NULL OR btrim(job) = '') AS job_empty,
  COUNT(*) FILTER (WHERE education IS NULL OR btrim(education) = '') AS education_empty,
  COUNT(*) FILTER (WHERE y IS NULL OR btrim(y) = '') AS outcome_empty
FROM raw.bank_marketing;

-- Step 9B: Inspect 'job' alphabetically to verify 'unknown' is recorded as text (330 rows)
SELECT job, COUNT(*) AS records
FROM raw.bank_marketing
GROUP BY job
ORDER BY job;


-- ============================================================================
-- WORK REQUEST 10: CHECK WHETHER VALUES LOOK VALID
-- Why: Hunt for spelling mistakes, weird labels, or non-numeric characters in 'age'.
-- ============================================================================

-- Step 10A: List only unique values (DISTINCT) in key categorical columns
SELECT DISTINCT y FROM raw.bank_marketing ORDER BY y;
SELECT DISTINCT contact FROM raw.bank_marketing ORDER BY contact;
SELECT DISTINCT month FROM raw.bank_marketing ORDER BY month;
SELECT DISTINCT day_of_week FROM raw.bank_marketing ORDER BY day_of_week;
SELECT DISTINCT poutcome FROM raw.bank_marketing ORDER BY poutcome;

-- Step 10B: Find any non-empty 'age' values that do NOT contain digits 0-9 only
-- Result: 0 rows returned (all 41,188 age values are clean whole numbers)
SELECT age, COUNT(*) AS records
FROM raw.bank_marketing
WHERE NULLIF(btrim(age), '') IS NOT NULL
  AND btrim(age) !~ '^[0-9]+$'
GROUP BY age;

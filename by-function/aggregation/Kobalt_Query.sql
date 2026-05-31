-- ============================================================
-- Query:       Kobalt Earnings (Publishing)
-- Table:       [operations].[KobaltEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized Kobalt publishing earnings for a
--              specific artist, grouped by agreement, work title,
--              writers, revenue source, and territory. Includes a
--              derived period end date parsed from the filename.
-- Notes:       Kobalt uses two distinct filename date formats,
--              each requiring a different parsing strategy:
--
--              Format 1 — Quarterly:  _Kobalt_YYYY-Q#.csv
--                Maps Q1–Q4 to the first month of each quarter.
--
--              Format 2 — Date range: _Kobalt_DD-Month-YYYY-DD-Month-YYYY--.csv
--                A start and end date are embedded in the filename,
--                separated by '--'. The CASE extracts the segment
--                between '_Kobalt_' and '--', then skips past the
--                second hyphen group to isolate the end date portion,
--                and replaces hyphens with spaces so TRY_CAST can
--                parse it as a 'DD Month YYYY' date string.
--
--              ESCAPE '\' is used in both LIKE patterns so that
--              the literal underscore '_' is matched exactly rather
--              than treated as the single-character wildcard.
-- ============================================================

SELECT
    k.agreement_id,
    k.work_title,
    k.writers,
    k.REVENUE_SOURCE_NAME,   -- Revenue category (e.g., streaming, sync, performance)
    k.territory,
    SUM(k.distributed_amount) AS Distributed_Amount,
    k.import_filename,

    CASE
        -- -------------------------------------------------------
        -- Format 1: _Kobalt_YYYY-Q#.csv  (e.g., _Kobalt_2024-Q3.csv)
        -- Extracts the 4-digit year, then maps the quarter digit
        -- to the first month of that quarter.
        -- -------------------------------------------------------
        WHEN k.import_filename LIKE '%\_Kobalt\_%[0-9][0-9][0-9][0-9]-Q[1-4]%' ESCAPE '\'
        THEN TRY_CAST(
            -- Extract YYYY
            SUBSTRING(k.import_filename, PATINDEX('%[0-9][0-9][0-9][0-9]-Q[1-4]%', k.import_filename), 4)
            + CASE SUBSTRING(k.import_filename, PATINDEX('%[0-9][0-9][0-9][0-9]-Q[1-4]%', k.import_filename) + 5, 1)
                WHEN '1' THEN '-01-01'   -- Q1 → January
                WHEN '2' THEN '-04-01'   -- Q2 → April
                WHEN '3' THEN '-07-01'   -- Q3 → July
                WHEN '4' THEN '-10-01'   -- Q4 → October
              END
        AS DATE)

        -- -------------------------------------------------------
        -- Format 2: _Kobalt_DD-Month-YYYY-DD-Month-YYYY--.csv
        -- The filename contains a date range. This logic:
        --   1. Locates '_Kobalt_' to find the start of the date block
        --   2. Uses '--' as the right boundary to isolate the full range
        --   3. Finds the third hyphen within that range to skip the
        --      start date and land on the end date (DD-Month-YYYY)
        --   4. Replaces hyphens with spaces → 'DD Month YYYY'
        --   5. TRY_CAST parses the result as a DATE
        -- -------------------------------------------------------
        WHEN k.import_filename LIKE '%\_Kobalt\_%[0-9][0-9]-%-[0-9][0-9][0-9][0-9]--%' ESCAPE '\'
        THEN TRY_CAST(
            REPLACE(
                SUBSTRING(
                    -- Isolate the full date range segment between '_Kobalt_' and '--'
                    SUBSTRING(
                        k.import_filename,
                        CHARINDEX('_Kobalt_', k.import_filename) + 8,
                        CHARINDEX('--', k.import_filename) - (CHARINDEX('_Kobalt_', k.import_filename) + 8)
                    ),
                    -- Skip past the third hyphen (end of start-date portion) to reach end date
                    CHARINDEX('-',
                        SUBSTRING(k.import_filename, CHARINDEX('_Kobalt_', k.import_filename) + 8, CHARINDEX('--', k.import_filename) - (CHARINDEX('_Kobalt_', k.import_filename) + 8)),
                        CHARINDEX('-',
                            SUBSTRING(k.import_filename, CHARINDEX('_Kobalt_', k.import_filename) + 8, CHARINDEX('--', k.import_filename) - (CHARINDEX('_Kobalt_', k.import_filename) + 8)),
                            CHARINDEX('-',
                                SUBSTRING(k.import_filename, CHARINDEX('_Kobalt_', k.import_filename) + 8, CHARINDEX('--', k.import_filename) - (CHARINDEX('_Kobalt_', k.import_filename) + 8))
                            ) + 1
                        ) + 1
                    ) + 1,
                    100  -- Take up to 100 chars (enough to capture 'DD-Month-YYYY')
                ),
            '-', ' ')   -- Replace hyphens with spaces → 'DD Month YYYY' for TRY_CAST
        AS DATE)

        ELSE NULL  -- No recognizable date pattern in filename
    END AS Period_End_Date

FROM
    [operations].[KobaltEarnings] k
WHERE
    k.Artist_Id = [ARTIST_ID]
GROUP BY
    k.agreement_id,
    k.work_title,
    k.writers,
    k.REVENUE_SOURCE_NAME,
    k.territory,
    k.import_filename
ORDER BY
    k.import_filename

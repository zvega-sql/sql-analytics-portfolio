-- ============================================================
-- Query:       STIM Earnings (Swedish Performing Rights)
-- Table:       [operations].[STIMEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized STIM earnings for a specific
--              artist, grouped by work title, sub-source, country,
--              and source file. Results are ordered most-recent
--              first by the date embedded in the filename.
-- Notes:       STIM filenames are expected to end with a
--              'YYYY-MM-DD' date string (10 characters) followed
--              by a 4-character extension (e.g., '.csv'), making
--              the date the 15th–6th characters from the end.
--              RIGHT(14) captures the last 14 characters; LEFT(10)
--              of that extracts the 'YYYY-MM-DD' portion, which
--              TRY_CAST handles directly without any reformatting.
--              sub_source indicates the type of performance
--              (e.g., radio, streaming, live) as categorized by STIM.
-- ============================================================

SELECT
    work_title,
    sub_source,             -- Performance type/category as defined by STIM
    country,
    IMPORT_FILENAME,

    -- Extract the date from the end of the filename.
    -- Assumes format: ...<anything>YYYY-MM-DD.csv
    -- RIGHT(14) → 'YYYY-MM-DD.csv' | LEFT(10) → 'YYYY-MM-DD'
    TRY_CAST(
        LEFT(RIGHT(IMPORT_FILENAME, 14), 10)
    AS DATE) AS Import_Date,

    SUM(AMOUNT) AS Total

FROM [operations].[STIMEarnings]
WHERE Artist_ID = [ARTIST_ID]
GROUP BY
    work_title,
    sub_source,
    country,
    IMPORT_FILENAME
ORDER BY
    Import_Date DESC,   -- Most recent statements first
    work_title

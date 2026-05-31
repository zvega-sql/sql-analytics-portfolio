-- ============================================================
-- Query:       BMI Earnings
-- Table:       [operations].[BMIEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized BMI performance royalties for a
--              specific artist, grouped by period, work title,
--              performance source, and territory.
-- Notes:       BMI reports by year + quarter rather than a calendar
--              date. PERIOD_YEAR and PERIOD_QUARTER together define
--              the statement window. W_OR_P indicates whether the
--              row reflects a Writer or Publisher share.
-- ============================================================

SELECT
    PERIOD_YEAR,               -- Calendar year of the performance period
    PERIOD_QUARTER,            -- Quarter of the performance period (1–4)
    PARTICIPANT_NAME,          -- Writer or publisher name on the work
    TITLE_NAME,                -- Song/work title as registered with BMI
    PERF_SOURCE,               -- Performance source (e.g., broadcast, streaming)
    COUNTRY_OF_PERFORMANCE,    -- Territory where the performance occurred
    W_OR_P,                    -- 'W' = Writer share, 'P' = Publisher share
    PARTICIPANT_NUM,           -- BMI participant identifier
    IMPORT_FILENAME,
    SUM(ROYALTY_AMOUNT) AS ROYALTY_AMOUNT
FROM
    [operations].[BMIEarnings]
WHERE
    Artist_Id = [ARTIST_ID]
GROUP BY
    PERIOD_YEAR,
    PERIOD_QUARTER,
    PARTICIPANT_NAME,
    TITLE_NAME,
    PERF_SOURCE,
    COUNTRY_OF_PERFORMANCE,
    W_OR_P,
    PARTICIPANT_NUM,
    IMPORT_FILENAME

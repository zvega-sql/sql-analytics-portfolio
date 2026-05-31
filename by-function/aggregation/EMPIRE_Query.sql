-- ============================================================
-- Query:       EMPIRE Earnings
-- Table:       [operations].[EmpireEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized EMPIRE earnings for a specific
--              artist, grouped by label, track, service, country,
--              and statement month.
-- Notes:       STATEMENT_DATE in the raw table is stored as a
--              formatted string like 'January 2024' (month-name +
--              year). To cast it to DATE, '01 ' is prepended and
--              style 106 ('DD Mon YYYY') is passed to CONVERT.
--              DATEADD/DATEDIFF then normalizes the result to the
--              first of the month, eliminating any day-of-month
--              variation.
--              NET__RAW_ has double underscores; this reflects the
--              raw column header as imported from EMPIRE CSVs.
-- ============================================================

SELECT
    label, 
    track_title, 
    track_artist, 
    [service],              -- DSP or distribution channel; bracketed due to reserved word
    country, 
    isrc, 
    upc_ean,

    -- Convert 'Month YYYY' string to a first-of-month DATE:
    -- Step 1: Prepend '01 ' → '01 January 2024'
    -- Step 2: CONVERT with style 106 parses 'DD Mon YYYY' format
    -- Step 3: DATEADD/DATEDIFF truncates to the 1st of the month
    CAST(
        DATEADD(
            MONTH,
            DATEDIFF(MONTH, 0, CONVERT(DATE, '01 ' + statement_date, 106)),
            0
        )
    AS DATE) AS statement_date,

    SUM(NET__RAW_) AS Net_Raw   -- Double underscore is part of the column name

FROM
    [operations].[EmpireEarnings]
WHERE
    Artist_ID = [ARTIST_ID]
GROUP BY
    label, 
    track_title, 
    track_artist, 
    [service], 
    country, 
    isrc, 
    upc_ean, 
    CAST(
        DATEADD(
            MONTH,
            DATEDIFF(MONTH, 0, CONVERT(DATE, '01 ' + statement_date, 106)),
            0
        )
    AS DATE)

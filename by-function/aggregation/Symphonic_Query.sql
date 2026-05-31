-- ============================================================
-- Query:       Symphonic Distribution Earnings
-- Table:       [operations].[SymphonicEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized Symphonic Distribution earnings
--              for a specific artist, grouped by track, DSP,
--              territory, release metadata, reporting period, and
--              source file. Includes both the raw period components
--              and a fully reconstructed DATE for use in Excel or
--              downstream reporting.
-- Notes:       REPORTING_PERIOD is stored as a 'Mon YY' string
--              (e.g., 'Jan 24'). It is split into two components:
--                month_reporting_period → LEFT(3) = 3-letter month
--                year_reporting_period  → RIGHT(2) = 2-digit year
--              Excel_Date reassembles these into a full date string
--              '01 Mon 20YY' and converts via TRY_CONVERT style 106
--              ('DD Mon YYYY'), producing a first-of-month DATE.
--              Both split components are included in the GROUP BY
--              because the derived Excel_Date expression references
--              them and cannot be used directly as a GROUP BY alias.
-- ============================================================

SELECT
    TRACK_TITLE, 
    track_artist, 
    LABEL, 
    DIGITAL_SERVICE_PROVIDER,      -- DSP (e.g., Spotify, Apple Music, Amazon)
    TERRITORY, 
    UPC_CODE, 
    ISRC_CODE,

    LEFT(REPORTING_PERIOD, 3) AS month_reporting_period,   -- 3-letter month abbreviation (e.g., 'Jan')
    RIGHT(REPORTING_PERIOD, 2) AS year_reporting_period,   -- 2-digit year (e.g., '24')

    -- Reconstruct a full first-of-month DATE from the 'Mon YY' period string:
    -- '01 ' + 'Jan' + ' 20' + '24' → '01 Jan 2024' → TRY_CONVERT style 106
    TRY_CONVERT(
        DATE,
        '01 ' + LEFT(REPORTING_PERIOD, 3) + ' 20' + RIGHT(REPORTING_PERIOD, 2),
        106   -- Style 106: 'DD Mon YYYY'
    ) AS Excel_Date,

    SUM(ROYALTY_DOLLAR_US) AS Total,
    IMPORT_FILENAME

FROM
    [operations].[SymphonicEarnings]
WHERE
    Artist_ID = [ARTIST_ID]
GROUP BY
    TRACK_TITLE, 
    track_artist, 
    LABEL, 
    DIGITAL_SERVICE_PROVIDER, 
    TERRITORY, 
    UPC_CODE, 
    ISRC_CODE, 
    LEFT(REPORTING_PERIOD, 3),    -- Must match SELECT expression exactly
    RIGHT(REPORTING_PERIOD, 2),   -- Must match SELECT expression exactly
    IMPORT_FILENAME

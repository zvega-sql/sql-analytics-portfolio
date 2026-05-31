-- ============================================================
-- Query:       SoundCloud Earnings
-- Table:       [operations].[SoundCloudEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized SoundCloud earnings for a specific
--              artist, grouped by accounting period, track metadata,
--              partner, country, and source file.
-- Notes:       SoundCloud reports by year + quarter rather than a
--              calendar date. ACCOUNTING_PERIOD_YEAR and
--              ACCOUNTING_PERIOD_QUARTER together define the window.
--              ARTIST_S_ and REVENUE__USD_ have trailing/double
--              underscores that reflect the raw column headers as
--              imported from SoundCloud CSVs (SoundCloud appends
--              underscores to column names with special characters).
--              [partner] is bracketed because PARTNER may conflict
--              with reserved words in some SQL Server contexts.
-- ============================================================

SELECT
    ACCOUNTING_PERIOD_YEAR,      -- Calendar year of the accounting period
    ACCOUNTING_PERIOD_QUARTER,   -- Quarter of the accounting period (1–4)
    TRACK,
    ARTIST_S_,                   -- Artist name; trailing underscore from raw CSV header
    ISRC,
    UPC,
    [partner],                   -- Distribution partner; bracketed for safety
    COUNTRY,
    SUM(REVENUE__USD_) AS Revenue_USD,  -- Double underscores reflect raw CSV header formatting
    IMPORT_FILENAME
FROM
    [operations].[SoundCloudEarnings]
WHERE
    Artist_Id = [ARTIST_ID]
GROUP BY
    ACCOUNTING_PERIOD_YEAR,
    ACCOUNTING_PERIOD_QUARTER,
    TRACK,
    ARTIST_S_,
    ISRC,
    UPC,
    [partner],
    COUNTRY,
    IMPORT_FILENAME

-- ============================================================
-- Query:       DistroKid Earnings
-- Table:       [operations].[DistrokidEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized DistroKid earnings for a specific
--              artist, grouped by artist, store, title, ISRC, UPC,
--              country of sale, reporting date, and source file.
-- Notes:       REPORTING_DATE is stored as a native date column
--              in this table, so no string parsing is required.
--              EARNINGS_USD_ has a trailing underscore in the column
--              name, reflecting the raw header from DistroKid CSVs.
-- ============================================================

SELECT
    artist,
    REPORTING_DATE,          -- Statement period; stored as DATE in this table
    store,                   -- DSP or distribution channel (e.g., Spotify, iTunes)
    title,
    isrc,
    upc,
    COUNTRY_OF_SALE,
    SUM(EARNINGS_USD_) AS Earnings_USD,  -- Trailing underscore is part of the column name
    IMPORT_FILENAME
FROM
    [operations].[DistrokidEarnings] 
WHERE 
    Artist_ID = [ARTIST_ID]
GROUP BY
    artist,
    REPORTING_DATE,
    store,
    title,
    isrc,
    upc,
    COUNTRY_OF_SALE,
    IMPORT_FILENAME

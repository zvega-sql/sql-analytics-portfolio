-- ============================================================
-- Query:       Cinq Music Earnings
-- Table:       [operations].[CinqEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized Cinq Music earnings for a specific
--              artist, grouped by account, label, source, period,
--              territory, and release/asset metadata.
-- Notes:       Cinq stores the accounting period as separate integer
--              year and month columns rather than a single date.
--              DATEFROMPARTS reconstructs these into a proper DATE
--              for downstream date-based filtering or sorting.
--              RELEASE_ARTIST is the album-level artist;
--              ASSET_ARTIST is the track-level artist (may differ
--              for compilations or featured works).
-- ============================================================

SELECT
    ACCOUNT_NAME, 
    LABEL_NAME,
    SOURCE,                    -- Revenue source (e.g., streaming, download, sync)
    ACCOUNTING_PERIOD_YEAR,    -- Integer year of the statement period
    ACCOUNTING_PERIOD_MONTH,   -- Integer month of the statement period
    -- Reconstruct a proper DATE from the split year/month columns
    DATEFROMPARTS(ACCOUNTING_PERIOD_YEAR, ACCOUNTING_PERIOD_MONTH, 1) AS Excel_Date,
    TERRITORY_CODE,
    UPC,
    RELEASE_TITLE,             -- Album or release title
    RELEASE_ARTIST,            -- Artist credited at the release (album) level
    ASSET_ARTIST,              -- Artist credited at the track (asset) level
    ASSET_TITLE,               -- Track title
    SUM(YOUR_EARNINGS) AS Your_Earnings,
    IMPORT_FILENAME
FROM 
    [operations].[CinqEarnings] 
WHERE
    Artist_ID = [ARTIST_ID]
GROUP BY
    ACCOUNT_NAME, 
    LABEL_NAME,
    SOURCE, 
    ACCOUNTING_PERIOD_YEAR,
    ACCOUNTING_PERIOD_MONTH,
    TERRITORY_CODE,
    UPC,
    RELEASE_TITLE, 
    RELEASE_ARTIST,
    ASSET_ARTIST,
    ASSET_TITLE, 
    IMPORT_FILENAME

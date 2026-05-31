-- ============================================================
-- Query:       Identity Music Earnings
-- Table:       [operations].[identitymusicearnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized earnings for a specific artist
--              from Identity Music, broken out by statement period,
--              label, track metadata, service, and territory.
-- Notes:       STATEMENT_PERIOD is stored as a 'YYYY-MM' string;
--              appending '-01' lets it cast cleanly to DATE.
-- ============================================================

SELECT
    IMPORT_FILENAME, 
    CONVERT(DATE, STATEMENT_PERIOD + '-01') AS STATEMENT_PERIOD,  -- Convert 'YYYY-MM' string to a proper DATE
    label,
    Artist, 
    track_title,
    upc,
    isrc,
    ACCOUNT_ID,
    [service],
    TERRITORY, 
    SUM(AMOUNT_DUE_IN_USD) AS Amount_Due_In_USD
FROM
    [operations].[identitymusicearnings] 
WHERE 
    Artist_ID = [ARTIST_ID]
GROUP BY
    IMPORT_FILENAME, 
    CONVERT(DATE, STATEMENT_PERIOD + '-01'),
    label,
    Artist, 
    track_title,
    upc,
    isrc,
    ACCOUNT_ID,
    [service],
    TERRITORY

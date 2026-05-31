-- ============================================================
-- Query:       Warner Chappell Music Earnings (Publishing)
-- Table:       [operations].[WarnerChappellEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized Warner Chappell publishing
--              earnings for a specific artist, grouped by work
--              title, composer, territory, exploitation source,
--              and source file. Includes a statement date parsed
--              from a fixed position in the filename.
-- Notes:       TANGO_WORK_TITLE refers to the work title as it
--              exists in Warner Chappell's internal Tango royalty
--              management system. This may differ from the
--              commercially released title.
--              EXPLOITATION_TERRITORY_NAME is WCM's full territory
--              name string (not an ISO code).
--              EXPLOITATION_SOURCE is WCM's classification for the
--              type of usage that generated the royalty (e.g.,
--              performance, mechanical, sync, print).
--              Statement_Date is parsed from the filename by taking
--              the last 25 characters and reading the first 10 of
--              those — expecting a 'YYYY-MM-DD' string at that
--              position. TRY_CAST returns NULL if the pattern is
--              absent or malformed.
--              Because Statement_Date is a computed expression, it
--              must be repeated verbatim in the GROUP BY.
-- ============================================================

SELECT
    TANGO_WORK_TITLE,           -- Work title in WCM's Tango royalty system
    COMPOSER, 
    EXPLOITATION_TERRITORY_NAME, -- Full territory name as reported by WCM
    EXPLOITATION_SOURCE,         -- Usage/exploitation type (e.g., performance, sync)
    SUM(AMOUNT_PAID) AS Amount_Paid, 
    IMPORT_FILENAME,

    -- Parse statement date from a fixed position in the filename.
    -- RIGHT(25) → last 25 characters; LEFT(10) → first 10 of those → 'YYYY-MM-DD'
    TRY_CAST(LEFT(RIGHT(IMPORT_FILENAME, 25), 10) AS DATE) AS Statement_Date

FROM 
    [operations].[WarnerChappellEarnings]
WHERE 
    Artist_Id = [ARTIST_ID]
GROUP BY
    TANGO_WORK_TITLE, 
    COMPOSER, 
    EXPLOITATION_TERRITORY_NAME, 
    EXPLOITATION_SOURCE, 
    IMPORT_FILENAME,
    TRY_CAST(LEFT(RIGHT(IMPORT_FILENAME, 25), 10) AS DATE)  -- Must match SELECT expression exactly

-- ============================================================
-- Query:       The Orchard Earnings
-- Table:       [operations].[TheOrchardEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized The Orchard earnings for a
--              specific artist, resolving schema variations across
--              multiple file generations before grouping and
--              aggregating. Three earnings pools (label share,
--              net share, and collaborator share) are combined
--              into a single Total_Earnings figure.
--              Results are ordered most-recent first.
-- Notes:       The Orchard has delivered statements in multiple
--              formats over time, with differing column names for
--              the same fields. The CTE resolves all variations
--              before the outer query aggregates, keeping the
--              GROUP BY clean and readable.
--
--              Report_Date logic (in priority order):
--                1. If STATEMENT_PERIOD is present: trim whitespace,
--                   replace '-' with ' ' → 'Mon YYYY' → prepend '01 '
--                   → TRY_CONVERT to DATE.
--                2. If STATEMENT_PERIOD is NULL but PERIOD_YEAR and
--                   PERIOD_QUARTER exist: assemble 'YYYY-Q-01'
--                   → TRY_CONVERT to DATE.
--                3. Otherwise: NULL.
--
--              Column resolution (COALESCE handles name changes):
--                Label:     IMPRINT_LABEL  → LABEL_IMPRINT
--                Track:     TRACK_NAME     → TRACK
--                Artist:    artist_name    → track_artist
--                Retailer:  RETAILER       → store
--                Territory: TERRITORY      → SALE_COUNTRY → COUNTRY
--                UPC:       ORCHARD_UPC    → DISPLAY_UPC
--
--              Earnings pools (ISNULL guards against NULLs in sum):
--                Label_Share      = LABEL_SHARE_NET_RECEIPTS
--                Net_Share        = NET_SHARE_ACCOUNT_CURRENCY
--                Collaborator_Share = COLLABORATOR_SHARE
--
--              See also: Imported_File_Query.sql — a companion query
--              for auditing which files have been loaded for this
--              same artist (3825) in this same table.
-- ============================================================

WITH CleanedData AS (
    SELECT
        -- Derive Report_Date from whichever period fields are populated
        CASE
            -- Priority 1: Parse STATEMENT_PERIOD ('Mon YYYY' string)
            WHEN TRIM(STATEMENT_PERIOD) IS NOT NULL
                THEN TRY_CONVERT(DATE, '01 ' + REPLACE(TRIM(STATEMENT_PERIOD), '-', ' '))

            -- Priority 2: Assemble from separate year/quarter columns
            WHEN TRIM(STATEMENT_PERIOD) IS NULL
                AND PERIOD_YEAR IS NOT NULL
                AND PERIOD_QUARTER IS NOT NULL
                THEN TRY_CONVERT(DATE, PERIOD_YEAR + '-' + PERIOD_QUARTER + '-01')

            ELSE NULL
        END AS Report_Date,

        STATEMENT_PERIOD,
        PERIOD_YEAR,
        PERIOD_QUARTER,

        -- Resolve column name differences across file generations
        COALESCE(IMPRINT_LABEL, LABEL_IMPRINT)      AS Imprint_Label,
        COALESCE(TRACK_NAME, TRACK)                 AS Track_Name,
        COALESCE(artist_name, track_artist)         AS Artist_Name,
        COALESCE(RETAILER, store)                   AS Retailer,
        COALESCE(TERRITORY, SALE_COUNTRY, COUNTRY)  AS Territory,
        COALESCE(ORCHARD_UPC, DISPLAY_UPC)          AS UPC,
        ISRC,

        -- Guard each earnings column against NULLs so the outer SUM is safe
        ISNULL(LABEL_SHARE_NET_RECEIPTS, 0)   AS Label_Share,
        ISNULL(NET_SHARE_ACCOUNT_CURRENCY, 0) AS Net_Share,
        ISNULL(COLLABORATOR_SHARE, 0)          AS Collaborator_Share,

        import_filename
    FROM
        [operations].[TheOrchardEarnings]
    WHERE
        Artist_ID = [ARTIST_ID]
)

SELECT
    Report_Date,
    STATEMENT_PERIOD,
    PERIOD_YEAR,
    PERIOD_QUARTER,
    Imprint_Label,
    Track_Name,
    Artist_Name,
    Retailer,
    Territory,
    UPC,
    ISRC,
    -- Combine all three earnings pools into a single total
    SUM(Label_Share + Net_Share + Collaborator_Share) AS Total_Earnings,
    import_filename
FROM
    CleanedData
GROUP BY
    Report_Date,
    STATEMENT_PERIOD,
    PERIOD_YEAR,
    PERIOD_QUARTER,
    Imprint_Label,
    Track_Name,
    Artist_Name,
    Retailer,
    Territory,
    UPC,
    ISRC,
    import_filename
ORDER BY
    Report_Date DESC,
    STATEMENT_PERIOD DESC   -- Secondary sort for rows where Report_Date is the same

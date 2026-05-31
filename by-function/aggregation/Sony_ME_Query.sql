-- ============================================================
-- Query:       Sony Music Entertainment Earnings
-- Table:       [operations].[SonyMusicEntertainmentEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized Sony Music Entertainment earnings
--              for a specific artist, grouped by account, contract,
--              track, partner, statement period, and source file.
--              Includes a derived period-ending date based on Sony's
--              semi-annual reporting cycle.
-- Notes:       Sony ME reports by half-year: STATEMENT_PERIOD is
--              stored as 'YYYY-H1' or 'YYYY-H2'.
--                H1 = January–June  → period ends June 30
--                H2 = July–December → period ends December 31
--              LEFT(4) extracts the year; RIGHT(2) checks 'H1'/'H2'
--              to assign month 6 or 12. DATEFROMPARTS constructs the
--              1st of that month and EOMONTH returns the last day.
-- ============================================================

SELECT
    ACCOUNT_NAME, 
    contract_no_,           -- Sony contract number
    TRACK_NAME, 
    PRODUCT_TITLE,
    product_artist,
    TRACK_ARTIST, 
    COUNTRY_OF_SALE, 
    [PARTNER],              -- Distribution partner; bracketed (reserved word)
    STATEMENT_PERIOD,       -- Semi-annual period string, e.g., '2024-H1' or '2024-H2'

    -- Derive the last day of the reporting half-year:
    -- H1 (Jan–Jun) → EOMONTH of June 1 → June 30
    -- H2 (Jul–Dec) → EOMONTH of December 1 → December 31
    EOMONTH(
        DATEFROMPARTS(
            LEFT(STATEMENT_PERIOD, 4),                                       -- Extract YYYY
            CASE WHEN RIGHT(STATEMENT_PERIOD, 2) = 'H1' THEN 6 ELSE 12 END, -- H1→6, H2→12
            1
        )
    ) AS Period_Ending_Date,

    SUM(ROYALTY_PAYABLE) AS Royalty_Payable, 
    IMPORT_FILENAME

FROM
    [operations].[SonyMusicEntertainmentEarnings]
WHERE
    Artist_Id = [ARTIST_ID]
GROUP BY
    ACCOUNT_NAME, 
    contract_no_, 
    TRACK_NAME, 
    TRACK_ARTIST, 
    PRODUCT_TITLE,
    product_artist,
    COUNTRY_OF_SALE, 
    [PARTNER], 
    STATEMENT_PERIOD, 
    IMPORT_FILENAME

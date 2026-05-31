-- ============================================================
-- Query:       La Oreja Music Group Earnings
-- Table:       [operations].[LaOrejaMusicGroupEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized La Oreja Music Group earnings for
--              a specific artist, grouped by statement period, sale
--              country, store, label, track metadata, and source file.
-- Notes:       STATEMENT_PERIOD is stored as a 'Mon YYYY' string
--              (e.g., 'Jan 2024'). Prepending '01 ' produces a
--              'DD Mon YYYY' string that CONVERT parses cleanly
--              using style 106. The outer CAST ensures the result
--              is returned as a DATE type.
--              DISPLAY_UPC is the consumer-facing UPC on the release.
-- ============================================================

SELECT
    IMPORT_FILENAME, 

    -- Convert 'Mon YYYY' string (e.g., 'Jan 2024') to a first-of-month DATE:
    -- '01 ' prepended → 'DD Mon YYYY' → CONVERT style 106 → DATE
    CAST(CONVERT(DATE, '01 ' + STATEMENT_PERIOD, 106) AS DATE) AS STATEMENT_PERIOD,

    SALE_COUNTRY, 
    STORE,                  -- DSP or distribution channel
    LABEL_IMPRINT,          -- Label imprint associated with the release
    TRACK, 
    PRODUCT,                -- Album or release title
    PRODUCT_ARTIST,         -- Artist credited at the release level
    DISPLAY_UPC,            -- Consumer-facing UPC
    ISRC, 
    SUM(REVENUE) AS Revenue_Sum

FROM 
    [operations].[LaOrejaMusicGroupEarnings] 
WHERE 
    Artist_ID = [ARTIST_ID]
GROUP BY
    IMPORT_FILENAME, 
    CAST(CONVERT(DATE, '01 ' + STATEMENT_PERIOD, 106) AS DATE),
    SALE_COUNTRY, 
    STORE, 
    LABEL_IMPRINT, 
    TRACK, 
    PRODUCT,
    PRODUCT_ARTIST,
    DISPLAY_UPC, 
    ISRC

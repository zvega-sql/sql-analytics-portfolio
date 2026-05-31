-- ============================================================
-- Query:       Vydia Earnings
-- Table:       [operations].[VydiaEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized Vydia earnings for a specific
--              artist, grouped by title, network, territory,
--              transaction date, and source file.
-- Notes:       TRANSACTION_DATE is stored as a native date column
--              in this table, so no string parsing is required.
--              NETWORK typically refers to the YouTube MCN (Multi-
--              Channel Network) or platform channel through which
--              the content was monetized. Vydia primarily handles
--              YouTube Content ID and social video monetization.
--              [DESCRIPTION] is bracketed because DESCRIPTION is a
--              reserved word in SQL Server; it contains Vydia's
--              internal label for the transaction type or usage
--              category (e.g., 'Content ID Claim', 'Direct Deal').
--              ALBUM_UPC is the UPC of the parent release associated
--              with the monetized asset.
-- ============================================================

SELECT
    TITLE,
    artist,
    NETWORK,            -- YouTube MCN or platform channel for the monetized content
    TERRITORY,
    TRANSACTION_DATE,   -- Date of the transaction; stored as DATE in this table
    ISRC,
    ALBUM_UPC,          -- UPC of the parent release associated with the asset
    IMPORT_FILENAME,
    [DESCRIPTION],      -- Transaction/usage type; bracketed (DESCRIPTION is reserved)
    SUM(USD_AMOUNT) AS USD_Amount
FROM 
    [operations].[VydiaEarnings]
WHERE 
    Artist_ID = [ARTIST_ID]
GROUP BY 
    TITLE,
    artist,
    NETWORK,
    TERRITORY,
    TRANSACTION_DATE,
    ISRC,
    ALBUM_UPC,
    IMPORT_FILENAME,
    [DESCRIPTION]

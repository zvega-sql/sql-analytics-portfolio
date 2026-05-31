-- ============================================================
-- Query:       FUGA Earnings
-- Table:       [operations].[FUGAEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized FUGA earnings for a specific
--              artist, grouped by track, DSP, release UPC, ISRC,
--              territory, and source file.
-- Notes:       No date column is present in this table; period
--              context must be inferred from IMPORT_FILENAME.
--              PRODUCT_UPC is the UPC of the parent release;
--              ASSET_ISRC is the ISRC of the individual track asset.
-- ============================================================

SELECT
    asset_title,              -- Track title
    asset_artist,             -- Track-level artist
    DSP,                      -- Digital service provider (e.g., Spotify, Apple Music)
    PRODUCT_UPC,              -- UPC of the parent album/release
    ASSET_ISRC,               -- ISRC of the individual track
    territory,
    SUM(REPORTED_ROYALTY) AS Reported_Royalty,
    IMPORT_FILENAME
FROM 
    [operations].[FUGAEarnings]
WHERE
    Artist_Id = [ARTIST_ID]
GROUP BY
    asset_title,
    asset_artist,
    DSP,
    PRODUCT_UPC,
    ASSET_ISRC,
    territory,
    IMPORT_FILENAME

-- ============================================================
-- Query:       United Masters / TriCast Earnings
-- Tables:      [operations].[UnitedMastersEarnings]
--              [operations].[TriCastEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized earnings for a specific artist
--              across both United Masters and TriCast, combined via
--              UNION ALL and aggregated together. Both tables share
--              the same schema, so results are treated as a single
--              dataset grouped by track, release metadata, and file.
-- Notes:       REPORT_DATE is derived by locating a 'YYYY-MM' pattern
--              in the filename via PATINDEX, extracting 7 characters,
--              and appending '-01' to produce a first-of-month DATE.
--              TRY_CAST is used so filenames without a valid 'YYYY-MM'
--              pattern return NULL rather than raising a hard error.
--              ASSET_ISRC is the ISRC at the track (asset) level;
--              PRODUCT_UPC is the UPC at the release level.
--              ASSET_NAME is the track title as registered with the
--              distributor (may differ from PRODUCT_TITLE).
-- ============================================================

WITH Combined AS (

    -- United Masters earnings
    SELECT
        IMPORT_FILENAME,
        ASSET_ISRC,
        PRODUCT_LABEL,
        PRODUCT_TITLE,
        PRODUCT_UPC,
        reported_royalty,
        ASSET_NAME,
        ARTIST_NAME
    FROM [operations].[UnitedMastersEarnings]
    WHERE Artist_ID = [ARTIST_ID]

    UNION ALL

    -- TriCast earnings (same schema as United Masters)
    SELECT
        IMPORT_FILENAME,
        ASSET_ISRC,
        PRODUCT_LABEL,
        PRODUCT_TITLE,
        PRODUCT_UPC,
        reported_royalty,
        ASSET_NAME,
        ARTIST_NAME
    FROM [operations].[TriCastEarnings]
    WHERE Artist_ID = [ARTIST_ID]

)

SELECT
    IMPORT_FILENAME,

    -- Parse the report month from a 'YYYY-MM' pattern in the filename.
    -- PATINDEX locates the pattern; SUBSTRING extracts 7 characters ('YYYY-MM');
    -- '-01' is appended to produce a valid first-of-month DATE.
    TRY_CAST(
        SUBSTRING(
            IMPORT_FILENAME,
            PATINDEX('%[0-9][0-9][0-9][0-9]-[0-9][0-9]%', IMPORT_FILENAME),
            7   -- 'YYYY-MM' is 7 characters
        ) + '-01'
    AS DATE) AS REPORT_DATE,

    ASSET_ISRC,         -- ISRC at the track (asset) level
    PRODUCT_LABEL,
    PRODUCT_TITLE,      -- Album or release title
    PRODUCT_UPC,        -- UPC at the release level
    SUM(reported_royalty) AS Reported_Royalty,
    ASSET_NAME,         -- Track title as registered with the distributor
    ARTIST_NAME

FROM Combined
GROUP BY
    IMPORT_FILENAME,
    ASSET_ISRC,
    PRODUCT_LABEL,
    PRODUCT_TITLE,
    PRODUCT_UPC,
    ASSET_NAME,
    ARTIST_NAME

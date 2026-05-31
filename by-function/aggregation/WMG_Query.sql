-- ============================================================
-- Query:       Warner Music Group (WMG) Recordings Earnings
-- Table:       [operations].[WMGEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized WMG recordings earnings for a
--              specific artist, grouped by account, release and
--              track metadata, DSP, country, and derived statement
--              date. Includes both release-level and track-level
--              artist fields.
-- Notes:       Statement_Date is parsed from the filename by:
--                1. Stripping the '.csv' extension with REPLACE
--                2. Taking the last 8 characters → 'YYYYMMDD'
--                3. TRY_CONVERT with style 112 (unseparated ISO
--                   date format) interprets 'YYYYMMDD' as a DATE.
--              Style 112 is the correct SQL Server conversion code
--              for the compact YYYYMMDD format without separators.
--              DIGITAL_SERVICE_PROVIDER_DSP_ has a trailing
--              underscore reflecting the raw column header from WMG
--              CSV exports (special characters are replaced with
--              underscores on import).
--              PRODUCT_ARTIST is the release-level artist credit;
--              TRACK_ARTIST is the individual track-level credit —
--              these may differ for compilations or featured works.
--              CATALOG_NUMBER is WMG's internal catalogue identifier
--              for the release.
-- ============================================================

SELECT
    ACCOUNT,                        -- WMG account code
    ACCOUNT_NAME,                   -- Account name associated with the royalty deal
    CATALOG_NUMBER,                 -- WMG internal catalogue identifier for the release
    PRODUCT_TITLE,                  -- Album or release title
    PRODUCT_ARTIST,                 -- Artist credited at the release level
    TRACK_NAME,
    TRACK_ARTIST,                   -- Artist credited at the track level (may differ from PRODUCT_ARTIST)
    DIGITAL_SERVICE_PROVIDER_DSP_,  -- DSP name; trailing underscore from raw CSV header
    COUNTRY, 

    -- Parse statement date from the last 8 characters of the filename (after removing '.csv').
    -- WMG filenames are expected to end in 'YYYYMMDD.csv'.
    -- Style 112 = 'YYYYMMDD' (compact ISO, no separators)
    TRY_CONVERT(DATE, RIGHT(REPLACE(IMPORT_FILENAME, '.csv', ''), 8), 112) AS Statement_Date,

    SUM(ROYALTY_PAYABLE) AS Royalty_Payable

FROM
    [operations].[WMGEarnings]
WHERE
    Artist_ID = [ARTIST_ID]
GROUP BY
    ACCOUNT, 
    ACCOUNT_NAME,
    CATALOG_NUMBER, 
    PRODUCT_TITLE, 
    PRODUCT_ARTIST, 
    TRACK_NAME, 
    TRACK_ARTIST, 
    DIGITAL_SERVICE_PROVIDER_DSP_, 
    COUNTRY,
    TRY_CONVERT(DATE, RIGHT(REPLACE(IMPORT_FILENAME, '.csv', ''), 8), 112)  -- Must match SELECT expression exactly

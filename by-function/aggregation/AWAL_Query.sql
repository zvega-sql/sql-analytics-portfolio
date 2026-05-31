-- ============================================================
-- Query:       AWAL Earnings
-- Table:       [operations].[AWALEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized AWAL earnings for a specific
--              artist. AWAL has delivered files in multiple formats
--              over time, so many columns are resolved via COALESCE
--              to handle schema variations across file generations.
-- Notes:       Statement_Date uses a 4-level COALESCE fallback to
--              parse the period date from different sources/formats.
--              File_Category flags whether a file contains Recording
--              Rights data, Revenue Details, or something else.
--              The earnings sum combines two amount columns that
--              appear in different file versions (NET_SHARE vs
--              DISTRIBUTED_AMOUNT).
-- ============================================================

SELECT
    -- Artist name: TRACK_ARTIST in newer files, ARTIST in older formats
    COALESCE(TRACK_ARTIST, ARTIST) AS TRACK_ARTIST,

    STATEMENT_PERIOD,

    -- Statement date resolution (in priority order):
    -- 1. Parse STATEMENT_PERIOD directly as 'DD Mon YYYY' format
    -- 2. Extract a date pattern from the filename (MM-MMMM-YYYY style)
    -- 3. Extract month/year from a filename segment with underscores
    -- 4. Fall back to a sentinel date (1900-01-01) if all else fails
    COALESCE(
        TRY_CAST('01 ' + REPLACE(STATEMENT_PERIOD, '-', ' ') AS DATE),
        TRY_CAST(SUBSTRING(IMPORT_FILENAME, PATINDEX('%[0-9][0-9]-[A-Z]%-[0-9][0-9][0-9][0-9]%', IMPORT_FILENAME), 17) AS DATE),
        TRY_CAST('01 ' + REPLACE(SUBSTRING(IMPORT_FILENAME, PATINDEX('%[A-Z]%_202[0-9]%', IMPORT_FILENAME), 15), '_', ' ') AS DATE),
        CAST('1900-01-01' AS DATE)  -- Sentinel: flags rows where date could not be parsed
    ) AS Statement_Date,

    -- Store/platform name: STORE in newer files, INCOMING_BATCH_SOURCE_NAME in older
    COALESCE(STORE, INCOMING_BATCH_SOURCE_NAME) AS STORE,

    -- Track name: TRACK in newer files, TRACK_TITLE in older
    COALESCE(TRACK, TRACK_TITLE) AS TRACK,

    -- ISRC: column name differs by file version
    COALESCE(ISRC, TRACK_ISRC) AS ISRC,

    -- UPC: column name differs by file version
    COALESCE(MANUFACTURER_UPC, BUNDLE_UPC_EAN) AS MANUFACTURER_UPC,

    -- Country/territory: column name differs by file version
    COALESCE(sale_country, TERRITORY_OF_SALE, COUNTRY) AS sale_country,

    IMPORT_FILENAME,

    -- Categorize file type based on filename keyword
    CASE 
        WHEN IMPORT_FILENAME LIKE '%Recording-Rights%' THEN 'Recording Rights'
        WHEN IMPORT_FILENAME LIKE '%revenue_details%'  THEN 'Revenue Details'
        ELSE 'Other' 
    END AS File_Category,

    -- Earnings: NET_SHARE_ACCOUNT_CURRENCY in newer files, DISTRIBUTED_AMOUNT in older;
    -- ISNULL used instead of COALESCE since both are cast to FLOAT first
    SUM(
        ISNULL(CAST(NET_SHARE_ACCOUNT_CURRENCY AS FLOAT), 0) + 
        ISNULL(CAST(DISTRIBUTED_AMOUNT AS FLOAT), 0)
    ) AS Net_share_account_currency

FROM [operations].[AWALEarnings]
WHERE Artist_Id = [ARTIST_ID]
GROUP BY 
    COALESCE(TRACK_ARTIST, ARTIST),
    STATEMENT_PERIOD,
    COALESCE(STORE, INCOMING_BATCH_SOURCE_NAME),
    COALESCE(TRACK, TRACK_TITLE),
    COALESCE(ISRC, TRACK_ISRC),
    COALESCE(MANUFACTURER_UPC, BUNDLE_UPC_EAN),
    COALESCE(sale_country, TERRITORY_OF_SALE, COUNTRY),
    IMPORT_FILENAME

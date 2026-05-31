-- ============================================================
-- Query:       DashGo Earnings
-- Table:       [operations].[DashGoEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized DashGo earnings for a specific
--              artist, grouped by store, region, artist/label,
--              track metadata, and source file. Includes a derived
--              report date parsed from the filename.
-- Notes:       DashGo filenames encode the statement month as
--              'MM-YY' near the end of the filename (last 8 chars
--              before the extension). The query reconstructs a
--              first-of-month DATE by reading those positions and
--              prepending '20' to the 2-digit year.
--              Example filename tail: ..._09-24.csv
--                 → LEN-5 to LEN-4 = '24' (year)  → '2024'
--                 → LEN-8 to LEN-7 = '09' (month) → '-09'
--                 → Result: '2024-09-01'
-- ============================================================

SELECT
    store,
    region,
    artist_name,
    label_name,
    track_artist,
    upc,
    track_title,
    isrc,
    IMPORT_FILENAME,

    -- Parse the report month from the filename.
    -- Reads a 2-digit year (positions near end) and a 2-digit month
    -- (slightly further from end), then builds a full DATE string.
    TRY_CONVERT(DATE, 
        '20' + SUBSTRING(IMPORT_FILENAME, LEN(IMPORT_FILENAME) - 5, 2)   -- YY → YYYY
        + '-' + SUBSTRING(IMPORT_FILENAME, LEN(IMPORT_FILENAME) - 8, 2)  -- MM
        + '-01'
    ) AS Report_Date,

    SUM(TRY_CONVERT(FLOAT, payable)) AS Payable  -- Cast required; payable may be stored as string

FROM
    [operations].[DashGoEarnings]
WHERE
    Artist_Id = [ARTIST_ID]
GROUP BY
    store,
    region,
    artist_name,
    label_name,
    track_artist,
    upc,
    track_title,
    isrc,
    IMPORT_FILENAME

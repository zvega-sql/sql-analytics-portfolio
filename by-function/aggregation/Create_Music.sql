-- ============================================================
-- Query:       Create Music Earnings
-- Table:       [operations].[CreateMusicEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized Create Music earnings for a
--              specific artist, grouped by track metadata, country,
--              store, and source file. Results are ordered
--              chronologically by the derived import month.
-- Notes:       Import_Month is parsed from the filename using a
--              nested SUBSTRING/CHARINDEX approach that locates the
--              second-to-last underscore segment in the filename
--              (expected to be a 'YYYY-MM' string) and appends
--              '-01' to produce a valid DATE. TRY_CONVERT protects
--              against filenames that don't follow the pattern.
-- ============================================================

SELECT
    Artist,
    title,
    label,
    isrc,
    upc,
    COUNTRY,
    store,
    SUM(RECIPIENT_NET_ROYALTY_DOLLARS_USD) AS Net_Royalty,
    IMPORT_FILENAME,

    -- Parse the statement month from the filename.
    -- Strategy: reverse the filename, find the second underscore to isolate
    -- the 'YYYY-MM' segment, then cast to DATE by appending '-01'.
    -- Example filename pattern: ..._YYYY-MM_<something>.csv
    TRY_CONVERT(
        DATE,
        CONCAT(
            LEFT(
                SUBSTRING(
                    IMPORT_FILENAME,
                    -- Jump past the last underscore segment to land on 'YYYY-MM'
                    LEN(IMPORT_FILENAME) - CHARINDEX('_', REVERSE(IMPORT_FILENAME), CHARINDEX('_', REVERSE(IMPORT_FILENAME)) + 1) + 2,
                    7  -- Take 7 characters: 'YYYY-MM'
                ),
                7
            ),
            '-01'  -- Append day to make a full DATE
        )
    ) AS Import_Month

FROM [operations].[CreateMusicEarnings]
WHERE Artist_Id = [ARTIST_ID]
GROUP BY
    Artist,
    title,
    label,
    isrc,
    upc,
    COUNTRY,
    store,
    IMPORT_FILENAME
ORDER BY Import_Month

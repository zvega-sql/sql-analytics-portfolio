-- ============================================================
-- Query:       SESAC Earnings (Performing Rights)
-- Table:       [operations].[SESACEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized SESAC performance royalties for a
--              specific artist, grouped by period, song, production,
--              source, society country, and source file. Includes a
--              derived first-of-quarter distribution date.
-- Notes:       SESAC reports earnings by calendar year + quarter
--              rather than a single date column. [YEAR] is bracketed
--              because YEAR is a reserved function name in SQL Server.
--              Distribution_Date maps QTR to the first month of that
--              quarter (Q1→Jan, Q2→Apr, Q3→Jul, Q4→Oct) using LIKE
--              patterns rather than exact equality, accommodating
--              label variations like 'Q1', '1st', etc.
--              PRODUCTION_TITLE and EPISODE_TITLE reflect sync/TV
--              usage context when the royalty originated from a
--              broadcast or streaming placement.
--              ESTABLISHMENT_SOURCE identifies the venue type or
--              broadcast network that generated the performance.
--              See also: Delete_Import_TS_Query.sql — this artist
--              (1059) has a corresponding cleanup query for stale rows.
-- ============================================================

SELECT
    [YEAR],                     -- Calendar year; bracketed (YEAR is a reserved function)
    QTR,                        -- Quarter label (e.g., 'Q1', '1', '1st Quarter')
    SONG_TITLE, 
    PRODUCTION_TITLE,           -- TV show, film, or production title (sync usage)
    EPISODE_TITLE,              -- Specific episode (sync usage)
    ESTABLISHMENT_SOURCE,       -- Venue or broadcast network originating the performance
    Artist, 
    SOCIETY_COUNTRY,            -- Country of the affiliated performing rights society
    SUM(Earnings) AS Earnings, 

    -- Derive a first-of-quarter DATE from the YEAR + QTR columns.
    -- LIKE patterns handle label variations across SESAC file formats.
    TRY_CAST(
        CAST([YEAR] AS VARCHAR) + '-' + 
        CASE 
            WHEN QTR LIKE '%1%' THEN '01'   -- Q1 → January
            WHEN QTR LIKE '%2%' THEN '04'   -- Q2 → April
            WHEN QTR LIKE '%3%' THEN '07'   -- Q3 → July
            WHEN QTR LIKE '%4%' THEN '10'   -- Q4 → October
            ELSE '01'                        -- Fallback if QTR is unrecognized
        END + '-01' 
    AS DATE) AS Distribution_Date,

    IMPORT_FILENAME

FROM
    [operations].[SESACEarnings]
WHERE
    Artist_ID = [ARTIST_ID]
GROUP BY
    [YEAR], 
    QTR, 
    SONG_TITLE, 
    PRODUCTION_TITLE, 
    EPISODE_TITLE, 
    ESTABLISHMENT_SOURCE, 
    Artist, 
    SOCIETY_COUNTRY, 
    IMPORT_FILENAME

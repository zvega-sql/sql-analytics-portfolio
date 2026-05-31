-- ============================================================
-- Query:       Too Lost Earnings
-- Table:       [operations].[TooLostEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized Too Lost earnings for a specific
--              artist, grouped by reporting date, track, channel,
--              country, release/track identifiers, and source file.
-- Notes:       REPORTING_DATE is stored as a native date column
--              in this table, so no string parsing is required.
--              CHANNEL reflects the distribution or monetization
--              channel through which the earnings were generated
--              (e.g., a DSP, YouTube Content ID, or social platform).
-- ============================================================

SELECT
    reporting_date,     -- Statement period date; stored as DATE in this table
    track_title,
    channel,            -- Distribution or monetization channel (DSP, YouTube CID, etc.)
    country,
    UPC,
    ISRC,
    SUM(total) AS Total,
    IMPORT_FILENAME
FROM 
    [operations].[TooLostEarnings]
WHERE 
    Artist_ID = [ARTIST_ID]
GROUP BY 
    reporting_date,
    track_title,
    channel,
    country,
    UPC,
    ISRC,
    IMPORT_FILENAME

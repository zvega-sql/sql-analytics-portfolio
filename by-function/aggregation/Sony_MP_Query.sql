-- ============================================================
-- Query:       Sony Music Publishing Earnings
-- Table:       [operations].[SonyMusicPublishingEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized Sony Music Publishing earnings for
--              a specific artist, grouped by song, writer, revenue
--              source, source country, and source file.
-- Notes:       Column names in this table use Sony's internal
--              abbreviated naming convention:
--                SRC2_NM   → Secondary revenue source name
--                           (e.g., ASCAP, PRS, streaming platform)
--                SRC2CTRY  → Country associated with that source
--                ROYAMT    → Royalty amount
--              No date column is available in this view; period
--              context must be inferred from IMPORT_FILENAME.
-- ============================================================

SELECT
    SONG,
    writer,
    SRC2_NM,        -- Secondary revenue source name (Sony internal abbreviation)
    SRC2CTRY,       -- Country associated with the secondary revenue source
    SUM(ROYAMT) AS Total,   -- ROYAMT = royalty amount (Sony internal abbreviation)
    IMPORT_FILENAME
FROM
    [operations].[SonyMusicPublishingEarnings]
WHERE
    Artist_Id = [ARTIST_ID]
GROUP BY
    SONG,
    writer,
    SRC2_NM,
    SRC2CTRY,
    IMPORT_FILENAME

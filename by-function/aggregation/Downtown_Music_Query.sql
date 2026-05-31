-- ============================================================
-- Query:       Downtown Music Earnings
-- Table:       [operations].[DowntownMusicEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized Downtown Music earnings for a
--              specific artist, grouped by store, region, artist,
--              label, UPC, track, ISRC, and source file.
-- Notes:       No date column is present in this table; period
--              context must be inferred from IMPORT_FILENAME.
--              This table shares the same basic structure as the
--              DashGo schema but without a parsed report date.
-- ============================================================

SELECT
    STORE,           -- DSP or distribution channel
    REGION,          -- Geographic region of the sale
    ARTIST_NAME,
    LABEL_NAME,
    UPC,
    TRACK_TITLE,
    ISRC,
    SUM(payable) AS Payable,
    IMPORT_FILENAME
FROM
    [operations].[DowntownMusicEarnings]
WHERE
    Artist_Id = [ARTIST_ID]
GROUP BY
    STORE,
    REGION,
    ARTIST_NAME,
    LABEL_NAME,
    UPC,
    TRACK_TITLE,
    ISRC,
    IMPORT_FILENAME

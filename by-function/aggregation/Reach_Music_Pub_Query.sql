-- ============================================================
-- Query:       Reach Music Publishing Earnings
-- Table:       [operations].[ReachMusicPublishingEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized Reach Music Publishing earnings
--              for a specific artist, grouped by revenue source,
--              contract, territory, track, and source file.
-- Notes:       No date column is present in this table; period
--              context must be inferred from IMPORT_FILENAME.
--              [CONTRACT_NAME] is bracketed as a precaution against
--              reserved-word conflicts. SOURCE indicates the revenue
--              category (e.g., mechanical, performance, sync).
-- ============================================================

SELECT
    source,                -- Revenue category (e.g., mechanical, performance, sync)
    [CONTRACT_NAME],       -- Publishing contract identifier; bracketed for safety
    territory,
    track_title,
    isrc,
    track_artist,
    import_filename,
    SUM(net_payable) AS Net_Payable
FROM
    [operations].[ReachMusicPublishingEarnings]
WHERE
    Artist_Id = [ARTIST_ID]
GROUP BY
    source,
    [CONTRACT_NAME],
    territory,
    track_title,
    isrc,
    track_artist,
    import_filename

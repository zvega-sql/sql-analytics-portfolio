-- ============================================================
-- Query:       Redeye Worldwide Earnings
-- Table:       [operations].[RedeyeEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized Redeye Worldwide earnings for a
--              specific artist, grouped by track, DSP, territory,
--              release metadata, received date, and source file.
--              Both base royalty and extended royalty amounts are
--              aggregated separately.
-- Notes:       RECEIVED_DATE is stored as a native date column
--              in this table, so no string parsing is required.
--              ROYALTY and EXTENDED are two distinct royalty pools
--              in Redeye's reporting — both are summed independently
--              to preserve the breakdown for downstream analysis.
--              EXTENDED typically reflects additional or bonus
--              royalty allocations beyond the base rate.
-- ============================================================

SELECT
    TRACK_TITLE,
    artist,
    label,
    DSP,                    -- Digital service provider (e.g., Spotify, Apple Music)
    TERRITORY,
    upc,
    isrc,
    RECEIVED_DATE,          -- Payment received date; stored as DATE in this table
    SUM(royalty) AS Royalty,         -- Base royalty amount
    SUM(EXTENDED) AS Extended,       -- Additional/extended royalty allocation
    import_filename
FROM 
    [operations].[RedeyeEarnings]
WHERE 
    Artist_ID = [ARTIST_ID]
GROUP BY 
    TRACK_TITLE,
    artist,
    label,
    DSP,
    TERRITORY,
    upc,
    isrc,
    RECEIVED_DATE,
    IMPORT_FILENAME

-- ============================================================
-- Query:       Royalti.io Earnings
-- Table:       [operations].[RoyaltiioEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized Royalti.io earnings for a specific
--              artist, grouped by DSP, track metadata, country,
--              reporting date, and source file.
-- Notes:       REPORTING_DATE is stored as a native date column
--              in this table, so no string parsing is required.
--              Royalti.io aggregates earnings from multiple upstream
--              sources, so DSP reflects the originating platform
--              rather than a single distributor.
-- ============================================================

SELECT
    DSP,                    -- Originating digital service provider
    ISRC,
    UPC,
    TRACK_TITLE,
    track_artist,
    COUNTRY,
    REPORTING_DATE,         -- Statement period date; stored as DATE in this table
    SUM(royalty) AS Royalty,
    IMPORT_FILENAME
FROM 
    [operations].[RoyaltiioEarnings] 
WHERE 
    Artist_ID = [ARTIST_ID]
GROUP BY
    DSP,
    ISRC,
    UPC,
    TRACK_TITLE,
    track_artist,
    COUNTRY,
    REPORTING_DATE,
    IMPORT_FILENAME

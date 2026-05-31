-- ============================================================
-- Query:       Songtrust Earnings
-- Table:       [operations].[SongtrustEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns total earnings per song per year for a
--              specific artist from Songtrust. This is a high-level
--              summary query — no territory, DSP, or source file
--              breakdown is included.
-- Notes:       PERIOD_YEAR is the only time dimension available
--              in this table; Songtrust does not report at the
--              quarterly or monthly level in this schema.
--              Expand the GROUP BY with additional columns
--              (e.g., territory, source) if finer detail is needed
--              and those columns exist in the table.
-- ============================================================

SELECT
    SONG_NAME,
    PERIOD_YEAR,            -- Calendar year of the earnings period
    SUM(amount) AS Total
FROM [operations].[SongtrustEarnings]
WHERE Artist_ID = [ARTIST_ID] 
GROUP BY
    PERIOD_YEAR,
    SONG_NAME

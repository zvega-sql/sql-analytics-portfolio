-- ============================================================
-- Query:       One Seven Music Earnings
-- Table:       [operations].[OneSevenEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns summarized One Seven Music earnings for a
--              specific artist, grouped by license type, title,
--              artist, territory, and source file.
-- Notes:       No date column is present in this table; period
--              context must be inferred from IMPORT_FILENAME.
--              LICENSE typically denotes the license type or
--              usage category under which the royalty was earned
--              (e.g., mechanical, sync, performance).
-- ============================================================

SELECT
    LICENSE,        -- License type or usage category for the royalty
    title,
    artist,
    TERRITORY,
    SUM(royalty) AS Royalty,
    IMPORT_FILENAME
FROM
    [operations].[OneSevenEarnings]
WHERE
    Artist_Id = [ARTIST_ID]
GROUP BY
    LICENSE,
    title,
    artist,
    TERRITORY,
    IMPORT_FILENAME

-- ============================================================
-- Query:       Imported File List (The Orchard)
-- Table:       [operations].[TheOrchardEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns a distinct list of all import filenames
--              on record for a specific artist from The Orchard
--              earnings table. Ordered alphabetically for easy
--              review.
-- Usage:       Use this to confirm which statement files have been
--              loaded, spot gaps in coverage, or verify a new
--              upload landed. Swap the table name and Artist_ID
--              to run the same check against any other source table.
-- ============================================================

SELECT DISTINCT
    IMPORT_FILENAME
FROM 
    [operations].[TheOrchardEarnings]
WHERE
    Artist_ID = [ARTIST_ID]
ORDER BY
    IMPORT_FILENAME  -- Alphabetical sort makes it easy to spot missing periods

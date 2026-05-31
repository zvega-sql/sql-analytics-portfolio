-- ============================================================
-- Query:       File Upload Check (Row Count Audit)
-- Table:       [operations].[SonyMusicPublishingEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns a distinct list of import filenames with
--              their row counts for a specific artist. Used to
--              confirm that a file uploaded successfully, to detect
--              duplicates, or to compare record counts against the
--              source CSV before and after import.
-- Usage:       Swap the table name and Artist_Id to run the same
--              audit against any other source earnings table.
-- ============================================================

SELECT
    DISTINCT IMPORT_FILENAME,
    COUNT(SonyMusicPublishingEarnings_Id) AS rows_count  -- Row count per imported file
FROM [operations].[SonyMusicPublishingEarnings]
WHERE artist_id = [ARTIST_ID]
GROUP BY IMPORT_FILENAME
ORDER BY IMPORT_FILENAME   -- Alphabetical order makes it easy to spot missing or duplicate files

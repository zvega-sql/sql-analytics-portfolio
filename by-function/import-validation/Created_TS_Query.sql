-- ============================================================
-- Query:       Import File Timestamp Audit (Created TS)
-- Table:       [operations].[BMIEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Returns the most recent CreatedTS (row insert
--              timestamp) per import file for a specific artist.
--              Ordered newest-first to quickly surface the latest
--              uploads.
-- Usage:       Use this to verify when a file was imported, confirm
--              a re-upload landed correctly, or identify the most
--              recent statement on record. Swap the table name and
--              Artist_ID to audit other source tables.
-- ============================================================

SELECT 
    IMPORT_FILENAME, 
    MAX(CreatedTS) AS Max_CreatedTS  -- Latest row insert time for each file
FROM [operations].[BMIEarnings]
WHERE Artist_ID = [ARTIST_ID]
GROUP BY IMPORT_FILENAME
ORDER BY Max_CreatedTS DESC          -- Most recently imported files appear first

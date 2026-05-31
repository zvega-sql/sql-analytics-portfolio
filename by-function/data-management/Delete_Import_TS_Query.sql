-- ============================================================
-- Query:       Delete Duplicate/Stale Import Rows
-- Table:       [dbo].[SESACEarnings]
-- Artist ID:   [ARTIST_ID]
-- Description: Removes rows for a specific artist that were inserted
--              before a given cutoff timestamp. Typically used to
--              clean up a prior import before re-uploading a
--              corrected file, or to remove rows from a superseded
--              data load.
-- ⚠ WARNING:   This is a destructive operation — deleted rows
--              cannot be recovered without a backup. Always verify
--              the target Artist_ID and CreatedTS cutoff in a
--              SELECT first before executing the DELETE.
-- Usage:       Update Artist_Id and the CreatedTS date threshold
--              to match the specific cleanup scenario.
-- ============================================================

-- Recommended pre-flight check (run as SELECT before DELETE):
-- SELECT COUNT(*) FROM [dbo].[SESACEarnings]
-- WHERE Artist_Id = [ARTIST_ID] AND CreatedTS < '[YYYYMMDD]'

DELETE FROM [dbo].[SESACEarnings] 
WHERE Artist_Id = [ARTIST_ID] 
  AND CreatedTS < '[YYYYMMDD]'  -- Remove all rows inserted before the specified cutoff date

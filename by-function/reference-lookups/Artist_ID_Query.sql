-- ============================================================
-- Query:       Artist ID Lookup
-- Table:       [operations].[Artist]
-- Description: Searches the Artist reference table for records
--              whose file-formatted name begins with a given prefix.
--              Used to look up an Artist_ID before running
--              earnings queries against source-specific tables.
-- Usage:       Replace '[ARTIST_NAME_PREFIX]%' with the target artist name prefix
--              (uppercase, as stored in ARTIST_NAME_FILE).
-- ============================================================

SELECT *
FROM [operations].[Artist]
WHERE ARTIST_NAME_FILE LIKE '[ARTIST_NAME_PREFIX]%'  -- Wildcard search; swap prefix as needed
